# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Actiontext' do
  next if Rails::VERSION::MAJOR < 6

  context 'when action text reflection' do
    let(:customer) { load_random(Customer) }

    before do
      visit motor_ui_data_path(['customers', customer.id])

      click_on 'Edit'
    end

    it 'updates field' do
      within '.ivu-drawer' do
        ivu_fill_field 'Bio', 'actiontext test'

        click_on 'Save'
      end

      page.driver.wait_for_network_idle

      expect(page).to have_content('actiontext test')
    end
  end

  context 'when richtext column type' do
    let(:product) { load_random(Product) }

    before do
      visit motor_ui_data_path(['products', product.id])

      click_on 'Edit'
    end

    it 'updates field' do
      within '.ivu-drawer' do
        ivu_fill_field 'Description', 'actiontext test'

        click_on 'Save'
      end

      page.driver.wait_for_network_idle

      expect(page).to have_content('actiontext test')
    end
  end
end
