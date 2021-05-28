# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Alerts' do
  describe 'alert page' do
    context 'when new' do
      let(:query) { load_random(Motor::Query) }

      before do
        visit new_motor_ui_alert_path
      end

      it 'saves alert' do
        ivu_fill_field 'Name', 'Test'
        ivu_fill_field 'Query', query.name
        ivu_fill_field 'Send to', 'test@example.com'
        ivu_fill_field 'Interval', 'every day at midnight'
        ivu_fill_field 'Timezone', 'UTC'
        ivu_fill_field 'Tags', %w[Sales Test]

        click_on 'Save', match: :first

        expect(page).to have_current_path(motor_ui_alert_path(Motor::Alert.last))
      end
    end
  end
end
