# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorization' do
  describe 'ops role' do
    let(:user) { User.find_by(role: 'ops') }

    before do
      login_as(user)
    end

    context 'when products table' do
      before do
        visit motor_ui_data_path('products')
      end

      it 'shows only permitted columns and actions' do
        expect(first('thead')).not_to have_content('Price')
        expect(first('thead')).not_to have_content('Image')

        within 'tbody' do
          first('.ivu-checkbox').click
        end

        ivu_dropdown_click 'Actions (1)', 'Edit'

        within '.ivu-drawer' do
          expect(page).to have_content 'Name'
          expect(page).not_to have_content 'Price'
        end
      end
    end

    context 'when orders table' do
      before do
        visit motor_ui_data_path('orders')
      end

      it 'shows only permitted records' do
        expect(page).to have_content "#{Order.joins(:customer).where(customers: { country_code: :US }).count} items"
      end
    end

    context 'when orders page' do
      context 'with shipped status' do
        before do
          orders = Order.joins(:customer).where(customers: { country_code: :US })
          order = load_random(orders).tap { |o| o.update(status: :shipped) }

          visit motor_ui_data_path(['orders', order.id])
        end

        it "doesn't show actions" do
          expect(page).not_to have_content 'Actions'
          expect(page).not_to have_selector '[data-role="edit"]', visible: false
        end
      end

      context 'with pending status' do
        before do
          orders = Order.joins(:customer).where(customers: { country_code: :US }, status: :pending)
          order = load_random(orders)

          visit motor_ui_data_path(['orders', order.id])
        end

        it "doesn't show customer field" do
          click_on 'Edit'

          within '.ivu-drawer' do
            expect(page).not_to have_content 'Customer'
          end
        end
      end
    end

    context 'when reports index' do
      before do
        visit motor_ui_reports_path
      end

      let(:dashboards) { Motor::Dashboard.joins(:tags).where(motor_tags: { name: %w[Orders Customers] }).active }
      let(:queries) { Motor::Query.all.active }
      let(:alerts) { Motor::Alert.joins(:tags).where(motor_tags: { name: 'Customers' }).active }

      it 'shows only items with permitted tags' do
        expect(page).to have_content "#{dashboards.count + queries.count + alerts.count} items"
      end
    end

    context 'when query show' do
      before do
        visit motor_ui_query_path(Motor::Query.find(10))
      end

      it 'shows edit button' do
        expect(page).to have_content 'Edit'
        expect(page).to have_content 'Revisions'
      end
    end

    context 'when dashboard show' do
      context 'when permitted dashboard' do
        let(:dashboard) { Motor::Dashboard.find(2) }

        before { visit motor_ui_dashboard_path(dashboard) }

        it "doesn't show edit button" do
          expect(page).not_to have_content 'Edit'
        end
      end

      context 'when restricted dashboard' do
        before do
          Capybara.raise_server_errors = false

          visit motor_ui_dashboard_path(dashboard)
        end

        after { Capybara.raise_server_errors = false }

        let(:dashboard) { Motor::Dashboard.find(1) }

        it 'sends unauthorized error' do
          expect(page).not_to have_content(dashboard.title)
        end
      end
    end

    context 'when alert show' do
      before do
        visit motor_ui_alert_path(load_random(Motor::Alert))
      end

      it "doesn't show save button" do
        expect(page).not_to have_content 'Save'
      end
    end

    context 'when form show' do
      before do
        forms = Motor::Form.joins(:tags).where(motor_tags: { name: %w[Orders Customers] })

        visit motor_ui_form_path(load_random(forms))
      end

      it "doesn't show save button" do
        expect(page).not_to have_content 'Save'
      end
    end
  end
end
