class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def self.up
    create_table :motor_queries do |t|
      t.column :name, :string, null: false
      t.column :description, :text
      t.column :sql_body, :text, null: false
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :string
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'name',
              name: 'motor_queries_name_unique_index',
              unique: true,
              where: 'deleted_at IS NULL'
    end

    create_table :motor_dashboards do |t|
      t.column :title, :string, null: false
      t.column :description, :text
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :string
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'title',
              name: 'motor_dashboards_title_unique_index',
              unique: true,
              where: 'deleted_at IS NULL'
    end

    create_table :motor_forms do |t|
      t.column :name, :string, null: false
      t.column :description, :text
      t.column :api_path, :text, null: false
      t.column :http_method, :string, null: false
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :string
      t.column :deleted_at, :datetime
      t.column :api_config_name, :string, null: false

      t.timestamps

      t.index :updated_at
      t.index 'name',
              name: 'motor_forms_name_unique_index',
              unique: true,
              where: 'deleted_at IS NULL'
    end

    create_table :motor_resources do |t|
      t.column :name, :string, null: false, index: { unique: true }
      t.column :preferences, :text, null: false

      t.timestamps

      t.index :updated_at
    end

    create_table :motor_configs do |t|
      t.column :key, :string, null: false, index: { unique: true }
      t.column :value, :text, null: false

      t.timestamps

      t.index :updated_at
    end

    create_table :motor_alerts do |t|
      t.references :query, null: false, foreign_key: { to_table: :motor_queries }, index: true
      t.column :name, :string, null: false
      t.column :description, :text
      t.column :to_emails, :text, null: false
      t.column :is_enabled, :boolean, null: false, default: true
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :string
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'name',
              name: 'motor_alerts_name_unique_index',
              unique: true,
              where: 'deleted_at IS NULL'
    end

    create_table :motor_alert_locks do |t|
      t.references :alert, null: false, foreign_key: { to_table: :motor_alerts }
      t.column :lock_timestamp, :string, null: false

      t.timestamps

      t.index %i[alert_id lock_timestamp], unique: true
    end

    create_table :motor_tags do |t|
      t.column :name, :string, null: false

      t.timestamps

      t.index 'name',
              name: 'motor_tags_name_unique_index',
              unique: true
    end

    create_table :motor_taggable_tags do |t|
      t.references :tag, null: false, foreign_key: { to_table: :motor_tags }, index: true
      t.column :taggable_id, :bigint, null: false
      t.column :taggable_type, :string, null: false

      t.index %i[taggable_id taggable_type tag_id],
              name: 'motor_polymorphic_association_tag_index',
              unique: true
    end

    create_table :motor_audits do |t|
      t.column :auditable_id, :string
      t.column :auditable_type, :string
      t.column :associated_id, :string
      t.column :associated_type, :string
      t.column :user_id, :bigint
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :audited_changes, :text
      t.column :version, :bigint, default: 0
      t.column :comment, :text
      t.column :remote_address, :string
      t.column :request_uuid, :string
      t.column :created_at, :datetime
    end

    create_table :motor_api_configs do |t|
      t.column :name, :string, null: false
      t.column :url, :string, null: false
      t.column :preferences, :text, null: false
      t.column :credentials, :text, null: false
      t.column :description, :text
      t.column :deleted_at, :datetime

      t.timestamps

      t.index 'name',
        name: 'motor_api_configs_name_unique_index',
        unique: true,
        where: 'deleted_at IS NULL'
    end

    create_table :motor_notes do |t|
      t.column :body, :text
      t.column :author_id, :bigint
      t.column :author_type, :string
      t.column :record_id, :string, null: false
      t.column :record_type, :string, null: false
      t.column :deleted_at, :datetime

      t.timestamps

      t.index %i[author_id author_type],
              name: 'motor_notes_author_id_author_type_index'
    end

    create_table :motor_note_tags do |t|
      t.column :name, :string, null: false

      t.timestamps

      t.index 'name',
              name: 'motor_note_tags_name_unique_index',
              unique: true
    end

    create_table :motor_note_tag_tags do |t|
      t.references :tag, null: false, foreign_key: { to_table: :motor_note_tags }, index: true
      t.references :note, null: false, foreign_key: { to_table: :motor_notes }, index: false

      t.index %i[note_id tag_id],
              name: 'motor_note_tags_note_id_tag_id_index',
              unique: true
    end

    create_table :motor_reminders do |t|
      t.column :author_id, :bigint, null: false
      t.column :author_type, :string, null: false
      t.column :recipient_id, :bigint, null: false
      t.column :recipient_type, :string, null: false
      t.column :record_id, :string
      t.column :record_type, :string
      t.column :scheduled_at, :datetime, null: false, index: true

      t.timestamps

      t.index %i[author_id author_type],
              name: 'motor_reminders_author_id_author_type_index'

      t.index %i[recipient_id recipient_type],
              name: 'motor_reminders_recipient_id_recipient_type_index'

      t.index %i[record_id record_type],
              name: 'motor_reminders_record_id_record_type_index'
    end

    create_table :motor_notifications do |t|
      t.column :title, :string, null: false
      t.column :description, :text
      t.column :recipient_id, :bigint, null: false
      t.column :recipient_type, :string, null: false
      t.column :record_id, :string
      t.column :record_type, :string
      t.column :status, :string, null: false

      t.timestamps

      t.index %i[recipient_id recipient_type],
              name: 'motor_notifications_recipient_id_recipient_type_index'

      t.index %i[record_id record_type],
              name: 'motor_notifications_record_id_record_type_index'
    end

    add_index :motor_audits, %i[auditable_type auditable_id version], name: 'motor_auditable_index'
    add_index :motor_audits, %i[associated_type associated_id], name: 'motor_auditable_associated_index'
    add_index :motor_audits, %i[user_id user_type], name: 'motor_auditable_user_index'
    add_index :motor_audits, :request_uuid
    add_index :motor_audits, :created_at

    model = Class.new(ApplicationRecord)

    model.table_name = 'motor_configs'

    model.create!(key: 'header.links', value: [{
      name: '⭐ Star on GitHub',
      path: 'https://github.com/motor-admin/motor-admin-rails'
    }].to_json)

    model.table_name = 'motor_api_configs'

    model.create!(name: 'origin', url: '/', preferences: {}, credentials: {})
  end

  def self.down
    drop_table :motor_audits
    drop_table :motor_alert_locks
    drop_table :motor_alerts
    drop_table :motor_forms
    drop_table :motor_taggable_tags
    drop_table :motor_tags
    drop_table :motor_resources
    drop_table :motor_configs
    drop_table :motor_queries
    drop_table :motor_dashboards
    drop_table :motor_api_configs
    drop_table :motor_note_tag_tags
    drop_table :motor_note_tags
    drop_table :motor_notes
    drop_table :motor_notifications
    drop_table :motor_reminders
  end
end
