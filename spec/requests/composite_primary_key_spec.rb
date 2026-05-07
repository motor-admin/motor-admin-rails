# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Composite primary key resource' do
  let(:product) { Product.first || create(:product) }
  let!(:inventories) do
    %w[WH001 WH002 WH003].map do |code|
      Inventory.create!(product: product, warehouse_code: code, quantity: code[-1].to_i * 10)
    end
  end

  let(:composite_id_for) do
    ->(inventory) { inventory.to_param }
  end

  describe 'schema discovery' do
    it 'includes the composite-PK model with primary_key as an array' do
      schema = Motor::BuildSchema::LoadFromRails.call

      inventory_schema = schema.find { |s| s[:class_name] == 'Inventory' }

      expect(inventory_schema).not_to be_nil
      expect(inventory_schema[:primary_key]).to eq(%w[product_id warehouse_code])
      expect(inventory_schema[:searchable_columns]).to include('product_id', 'warehouse_code')
    end

    it 'marks each primary-key column as read_only' do
      schema = Motor::BuildSchema::LoadFromRails.call
      inventory_schema = schema.find { |s| s[:class_name] == 'Inventory' }

      pk_columns = inventory_schema[:columns].select { |c| %w[product_id warehouse_code].include?(c[:name]) }

      expect(pk_columns.map { |c| c[:access_type] }).to all(eq(Motor::BuildSchema::ColumnAccessTypes::READ_ONLY))
    end
  end

  describe 'GET /api/data/inventories' do
    it 'lists records' do
      get '/api/data/inventories'

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data'].size).to eq(inventories.size)
    end

    it 'returns the row count via meta' do
      get '/api/data/inventories', params: { meta: 'count', page: { limit: 0 } }

      body = JSON.parse(response.body)

      expect(body['meta']['count']).to eq(inventories.size)
    end

    it 'sorts by all primary-key columns descending' do
      get '/api/data/inventories', params: { sort: '-product_id,-warehouse_code' }

      body = JSON.parse(response.body)

      expect(body['data'].map { |r| r['warehouse_code'] }).to eq(inventories.map(&:warehouse_code).sort.reverse)
    end
  end

  describe 'GET /api/data/inventories/:id' do
    it 'finds a record by composite PK string' do
      target = inventories.first

      get "/api/data/inventories/#{composite_id_for.call(target)}"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body['data']['warehouse_code']).to eq(target.warehouse_code)
      expect(body['data']['product_id']).to eq(target.product_id)
    end

    it 'returns 404 for a non-existent composite PK' do
      get "/api/data/inventories/#{product.id}_NOPE"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/data/inventories' do
    it 'creates a record' do
      post '/api/data/inventories',
           params: { data: { product_id: product.id, warehouse_code: 'WH999', quantity: 7 } },
           as: :json

      expect(response).to have_http_status(:ok)

      expect(Inventory.find_by(product_id: product.id, warehouse_code: 'WH999')).not_to be_nil
    end
  end

  describe 'PUT /api/data/inventories/:id' do
    it 'updates the record found by composite PK' do
      target = inventories.first

      put "/api/data/inventories/#{composite_id_for.call(target)}",
          params: { data: { quantity: 999 } },
          as: :json

      expect(response).to have_http_status(:ok)

      expect(target.reload.quantity).to eq(999)
    end
  end

  describe 'DELETE /api/data/inventories/:id' do
    it 'destroys the record found by composite PK' do
      target = inventories.first

      delete "/api/data/inventories/#{composite_id_for.call(target)}"

      expect(response).to have_http_status(:ok)

      expect(Inventory.exists?(product_id: target.product_id, warehouse_code: target.warehouse_code)).to be(false)
    end
  end

  describe 'single-PK regression' do
    let!(:single_pk_product) { create(:product) }

    it 'still discovers single-PK models with a string primary_key' do
      schema = Motor::BuildSchema::LoadFromRails.call

      product_schema = schema.find { |s| s[:class_name] == 'Product' }

      expect(product_schema[:primary_key]).to eq('id')
    end

    it 'reports a usable count for single-PK relations via meta' do
      relation = Product.all
      meta = Motor::ApiQuery::BuildMeta.call(relation, ActionController::Parameters.new(meta: 'count'))

      expect(meta[:count]).to be >= 1
    end

    it 'serializes single-PK records' do
      relation = Product.all
      json = Motor::ApiQuery::BuildJson.call(relation, ActionController::Parameters.new)

      expect(json).to be_an(Array)
      expect(json.first).to include('id')
    end
  end

  describe 'BuildJson rendering' do
    it 'serializes composite-PK records without invoking arel-table primary-key shortcuts' do
      relation = Inventory.all
      json = Motor::ApiQuery::BuildJson.call(relation, ActionController::Parameters.new)

      expect(json.size).to eq(inventories.size)
      expect(json.first.keys).to include('product_id', 'warehouse_code')
    end

    it 'reports a usable count even when primary_key is composite' do
      relation = Inventory.all
      meta = Motor::ApiQuery::BuildMeta.call(relation, ActionController::Parameters.new(meta: 'count'))

      expect(meta[:count]).to eq(inventories.size)
    end
  end
end
