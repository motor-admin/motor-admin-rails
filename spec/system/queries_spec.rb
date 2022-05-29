# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Queries' do
  describe 'query page' do
    context 'when new' do
      let(:sql_query) do
        <<~SQL.squish
          SELECT id as customer_id, name, email, created_at FROM customers ORDER BY id DESC;
        SQL
      end

      before do
        visit new_motor_ui_query_path
      end

      it 'saves query' do
        find('.ace_text-input', visible: false).fill_in(with: sql_query)

        find('[data-role="run"]').click

        within '.ivu-table-tbody > .ivu-table-row:nth-child(1)' do
          expect(page).to have_content(Customer.last.email)
          expect(page).to have_link(href: motor_ui_data_path(['customers', Customer.last.id]))
        end

        click_on 'Settings'
        click_on 'Settings'
        click_on 'Save'

        within '.ivu-modal' do
          ivu_fill_field 'Tags', %w[Stats Test]
          ivu_fill_field 'Name', 'Test'
          ivu_fill_field 'Description', 'Test', click: true

          click_on 'Save'
        end

        expect(page).to have_current_path(motor_ui_query_path(Motor::Query.last))
      end
    end

    context 'with hash params' do
      let(:hash) do
        <<~TEXT.gsub(/[\n\s]/, '')
          eyJzcWxfYm9keSI6IlNFTEVDVCBuYW1lLCBjb3VudCgxKVxuRlJPTS
          BjdXN0b21lcnMgYXMgY3NcbkpPSU4gb3JkZXJzIGFzIG9kIE9OIG9k
          LmN1c3RvbWVyX2lkID0gY3MuaWRcbkdST1VQIEJZIDE7IiwicHJlZm
          VyZW5jZXMiOnsidmlzdWFsaXphdGlvbiI6ImJhcl9jaGFydCIsInZp
          c3VhbGl6YXRpb25fb3B0aW9ucyI6eyJsYWJlbF9mb3JtYXQiOiJkZW
          NpbWFsIiwibGFiZWxfZm9ybWF0X29wdGlvbnMiOnt9LCJjaGFydF92
          YWx1ZXNfYXhpcyI6ZmFsc2UsImNoYXJ0X3N0YWNrZWQiOmZhbHNlfS
          widmFyaWFibGVzIjpbXX19
        TEXT
      end

      before do
        visit new_motor_ui_query_path(anchor: hash)
      end

      it 'applies query params from hash' do
        expect(page).to have_content 'SELECT name, count(1)'

        click_on 'Settings'

        expect(first('.ivu-radio-wrapper-checked')).to have_content 'Bar chart'
      end
    end
  end
end
