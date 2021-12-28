# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resources' do
  describe 'resources home' do
    before do
      visit motor_admin_path
    end

    it 'contains navigation links' do
      expect(page).to have_link 'Products', href: motor_ui_data_path('products')
      expect(page).to have_link 'Orders', href: motor_ui_data_path('orders')
      expect(page).to have_link 'Customers', href: motor_ui_data_path('customers')
      expect(page).to have_link 'Notes', href: motor_ui_data_path('notes')
      expect(page).to have_link 'Reports', href: motor_ui_reports_path
      expect(page).to have_link 'Forms', href: motor_ui_forms_path
      expect(page).to have_link 'Sales Dashboard', href: motor_ui_dashboard_path(1)
    end
  end

  describe 'products table' do
    before do
      visit motor_ui_data_path('products')
    end

    context 'when index table' do
      let(:product) { Product.last }

      it 'renders columns correctly' do
        first_row = find('.ivu-table-tbody > .ivu-table-row:nth-child(1)')

        within(first_row) do
          expect(page).to have_content product.name
          expect(page).to have_content number_to_currency(product.price / 100)
          expect(page).to have_content I18n.l(product.created_at, format: '%b %-d, %Y, %-I:%M %p')
          expect(page.find('img')[:src]).to end_with product.image.path
        end

        first_row.click

        expect(page).to have_current_path(motor_ui_data_path(['products', product.id]))
      end
    end

    context 'with search' do
      let(:product) { load_random(Product) }

      it 'returns 1 row' do
        search_input = find('input[placeholder="Search products..."]')

        search_input.fill_in(with: product.name)
        search_input.native.send_keys(:enter)

        page.driver.wait_for_network_idle

        expect(page).to have_content product.name

        expect(page).to have_content '1 item'
      end
    end

    context 'with filter' do
      let(:customer) { load_random(Customer) }
      let(:products) { customer.line_items.map(&:product).uniq }

      it 'applies filters' do
        find('[data-role="filter"]').click

        within '.ivu-drawer' do
          ivu_select(find('[data-role="filter-field"]'), 'Customers - Email')

          find('[data-role="filter-value"]').fill_in(with: customer.email)

          click_on 'Apply'
        end

        expect(page).to have_current_path(
          motor_ui_data_path('products', { filter: { '0' => { customers: { email: { eq: customer.email } } } } })
        )

        page.driver.wait_for_network_idle

        expect(page).to have_content "#{products.size} item#{'s' if products.size > 1}"
      end
    end

    context 'when new' do
      let(:product_attributes) { attributes_for(:product) }

      it 'creates new row' do
        find('[data-role="new"]').click

        within '.ivu-drawer' do
          ivu_fill_field 'Name', product_attributes[:name]
          ivu_fill_field 'Release year', product_attributes[:release_year]
          ivu_fill_field 'Category', product_attributes[:category].titleize
          ivu_fill_field 'Description', product_attributes[:description]
          ivu_fill_field 'Price', product_attributes[:price]
          find('input[type="file"]').set('spec/fixtures/logo.png')

          click_on 'Save'
        end

        page.driver.wait_for_network_idle

        within '.ivu-table-tbody > .ivu-table-row:nth-child(1)' do
          expect(page).to have_content(product_attributes[:name])
          expect(page).to have_content(product_attributes[:description])
        end
      end
    end
  end

  describe 'customer page' do
    let(:customer) { load_random(Customer) }

    before do
      visit motor_ui_data_path(['customers', customer.id])
    end

    context 'when edit inline' do
      it 'updates record' do
        expect(page).to have_content(customer.name)

        cell = find(:xpath, "//div[./b[starts-with(text(), 'Name')]]")
        cell.find('[data-role="edit"]', visible: false).click

        within cell do
          fill_in with: 'test'
        end

        cell.find('.ion-md-checkmark').click

        expect(page).not_to have_content(customer.name)
        expect(page).to have_content(customer.reload.name)
      end
    end

    context 'when edit form' do
      it 'updates record' do
        expect(page).to have_content(customer.email)

        click_on 'Edit'

        within '.ivu-drawer' do
          ivu_fill_field 'Email', 'test@test.com'

          click_on 'Save'
        end

        page.driver.wait_for_network_idle

        expect(page).not_to have_content(customer.email)
        expect(page).to have_content(customer.reload.email)
      end

      it 'buils custom form' do
        click_on 'Edit'

        within '.ivu-drawer' do
          find('.ivu-dropdown').click
          find('li', text: 'Build custom form').click
        end

        within "[data-role='editor']" do
          click_on 'Add Field'
          ivu_fill_field 'Name', 'Test Field'
          click_on 'Add'
        end

        click_on 'Save'

        within '.ivu-modal' do
          ivu_fill_field 'API', 'Origin'
          ivu_fill_field 'Path', '/test'

          click_on 'Save'
        end

        page.driver.wait_for_network_idle

        visit motor_ui_data_path(['customers', customer.id])

        click_on 'Edit'

        expect(page).to have_content 'Test Field'
      end
    end
  end
end
