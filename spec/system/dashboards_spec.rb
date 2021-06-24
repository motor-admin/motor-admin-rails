# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboards' do
  describe 'dashboard page' do
    context 'when new' do
      let(:customer) { load_random(Customer) }

      before do
        visit new_motor_ui_dashboard_path
      end

      it 'saves dashboard' do
        first('p', text: 'New customers').click

        click_on 'Add Query'
        first('p', text: 'Best performance result').click

        click_on 'Add Query'
        first('p', text: 'Customer total sales per month').click

        ivu_fill_field 'Customer', customer.id

        click_on 'Save'

        within '.ivu-modal' do
          ivu_fill_field 'Tags', %w[Stats Test]
          ivu_fill_field 'Title', 'Test'
          ivu_fill_field 'Description', 'Test', click: true

          click_on 'Save'
        end

        expect(page).to have_current_path(motor_ui_dashboard_path(Motor::Dashboard.last))
      end
    end
  end
end
