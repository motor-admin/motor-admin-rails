# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Forms' do
  describe 'form page' do
    context 'when new' do
      before do
        visit new_motor_ui_form_path
      end

      it 'saves form' do
        click_on 'Add Field'
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
          ivu_fill_field 'Name', 'Test'
          ivu_fill_field 'Path', '/test'
          ivu_fill_field 'Description', 'Test', click: true

          click_on 'Save'
        end

        expect(page).to have_current_path(motor_ui_form_path(Motor::Form.last))
      end
    end

    context 'when existing' do
      let(:order) { load_random(Order) }

      before do
        visit motor_ui_form_path(Motor::Form.find(1))
      end

      it 'cancels order' do
        ivu_fill_field 'Order', order.address_line_one
        ivu_fill_field 'Reason', 'test'

        click_on 'Submit', match: :first

        expect(order.reload.status).to eq 'canceled'
      end
    end
  end
end
