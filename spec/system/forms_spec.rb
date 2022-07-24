# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Forms' do
  describe 'form page' do
    context 'when new' do
      before do
        visit new_motor_ui_form_path
      end

      it 'saves form' do
        click_on 'Add Field', match: :first
        ivu_fill_field 'Name', 'Test'
        click_on 'Add'

        click_on 'Add Field'
        ivu_fill_field 'Name', 'Test 2'
        ivu_fill_field 'Type', 'Number'
        click_on 'Add'

        click_on 'Add Field'
        ivu_fill_field 'Name', 'Test 3'
        ivu_fill_field 'Type', 'Checkbox'
        click_on 'Add'

        click_on 'Save'

        within '.ivu-modal' do
          ivu_fill_field 'Tags', %w[Stats Test]
          ivu_fill_field 'Name', 'Test', click: true
          ivu_fill_field 'API', 'Origin', click: true
          ivu_fill_field 'Path', '/test', click: true
          ivu_fill_field 'Description', 'Test', click: true

          click_on 'Save'
        end

        expect(page).to have_current_path(motor_ui_form_path(Motor::Form.last))
      end
    end

    context 'when existing' do
      before do
        visit motor_ui_form_path(form)
      end

      describe 'cancel order form' do
        let(:form) { Motor::Form.find(1) }
        let(:order) { load_random(Order) }

        it 'cancels order' do
          ivu_fill_field 'Order', order.address_line_one
          ivu_fill_field 'Reason', 'test'

          click_on 'Submit', match: :first

          expect(order.reload.status).to eq 'canceled'
        end
      end

      describe 'order update form' do
        let(:form) { Motor::Form.find(3) }
        let(:order) { Order.find(23) }
        let(:product) { load_random(Product) }

        it 'updates order line items' do
          ivu_fill_field 'Order', order.address_line_one

          ivu_fill_field 'Line items', product.name

          expect(page).to have_content(product.name)

          click_on 'Submit', match: :first

          expect(order.line_items.reload.map(&:product)).to include(product)
        end
      end

      describe 'new order form' do
        let(:form) { Motor::Form.find(2) }
        let(:order_attrs) { attributes_for(:order) }
        let(:customer_attrs) { attributes_for(:customer) }

        context 'when valid form' do
          it 'creates new order' do
            ivu_fill_field 'Address line one', order_attrs[:address_line_one]
            ivu_fill_field 'Address line two', order_attrs[:address_line_two]
            ivu_fill_field 'Region', 'Midwest'
            ivu_fill_field 'Address state', 'Michigan'
            ivu_fill_field 'Address city', order_attrs[:address_city]
            ivu_fill_field 'Address ZIP', order_attrs[:address_zip]
            ivu_fill_field 'Email', customer_attrs[:email]
            ivu_fill_field 'Name', customer_attrs[:name]
            ivu_fill_field 'Country', load_random(Country).name
            ivu_fill_field 'Product', load_random(Product).id
            ivu_fill_field 'Price', (rand * 100).to_i + 1
            ivu_fill_field 'Quantity', (rand * 4).to_i + 1
            ivu_fill_field 'Body', 'Test'

            click_on 'Submit', match: :first

            expect(page).to have_content 'Form has been submitted successfully'
          end
        end

        context 'when invalid form' do
          it 'shows validator errors' do
            click_on 'Submit', match: :first

            expect(page).to have_content('Address line two is required')
            expect(page).to have_content('Body is required')
            expect(page).to have_content('Price is required')
          end
        end
      end
    end
  end
end
