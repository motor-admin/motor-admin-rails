class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def self.up
    create_table :motor_queries do |t|
      t.column :name, :text, null: false
      t.column :description, :text
      t.column :sql_body, :text, null: false
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :text
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'name',
              name: 'motor_queries_name_unique_index',
              unique: true,
              where: 'deleted_at IS NULL',
              length: { name: 255 }
    end

    create_table :motor_dashboards do |t|
      t.column :title, :text, null: false
      t.column :description, :text
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :text
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'title',
              name: 'motor_dashboards_title_unique_index',
              unique: true,
              where: 'deleted_at IS NULL',
              length: { title: 255 }
    end

    create_table :motor_forms do |t|
      t.column :name, :text, null: false
      t.column :description, :text
      t.column :api_path, :text, null: false
      t.column :http_method, :text, null: false
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :text
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'name',
              name: 'motor_forms_name_unique_index',
              unique: true,
              where: 'deleted_at IS NULL',
              length: { name: 255 }
    end

    create_table :motor_resources do |t|
      t.column :name, :text, null: false, index: { unique: true, length: 255 }
      t.column :preferences, :text, null: false

      t.timestamps

      t.index :updated_at
    end

    create_table :motor_configs do |t|
      t.column :key, :text, null: false, index: { unique: true, length: 255 }
      t.column :value, :text, null: false

      t.timestamps

      t.index :updated_at
    end

    create_table :motor_alerts do |t|
      t.references :query, null: false, foreign_key: { to_table: :motor_queries }, index: true
      t.column :name, :text, null: false
      t.column :description, :text
      t.column :to_emails, :text, null: false
      t.column :is_enabled, :boolean, null: false, default: true
      t.column :preferences, :text, null: false
      t.column :author_id, :bigint
      t.column :author_type, :text
      t.column :deleted_at, :datetime

      t.timestamps

      t.index :updated_at
      t.index 'name',
              name: 'motor_alerts_name_unique_index',
              unique: true,
              where: 'deleted_at IS NULL',
              length: { name: 255 }
    end

    create_table :motor_alert_locks do |t|
      t.references :alert, null: false, foreign_key: { to_table: :motor_alerts }
      t.column :lock_timestamp, :text, null: false

      t.timestamps

      t.index %i[alert_id lock_timestamp], unique: true, length: { lock_timestamp: 255 }
    end

    create_table :motor_tags do |t|
      t.column :name, :text, null: false

      t.timestamps

      t.index 'name',
              name: 'motor_tags_name_unique_index',
              unique: true,
              length: { name: 255 }
    end

    create_table :motor_taggable_tags do |t|
      t.references :tag, null: false, foreign_key: { to_table: :motor_tags }, index: true
      t.column :taggable_id, :bigint, null: false
      t.column :taggable_type, :text, null: false

      t.index %i[taggable_id taggable_type tag_id],
              name: 'motor_polymorphic_association_tag_index',
              unique: true,
              length: { taggable_type: 255 }
    end

    create_table :motor_audits do |t|
      t.column :auditable_id, :bigint
      t.column :auditable_type, :text
      t.column :associated_id, :bigint
      t.column :associated_type, :text
      t.column :user_id, :bigint
      t.column :user_type, :text
      t.column :username, :text
      t.column :action, :text
      t.column :audited_changes, :text
      t.column :version, :bigint, default: 0
      t.column :comment, :text
      t.column :remote_address, :text
      t.column :request_uuid, :text
      t.column :created_at, :datetime
    end

    add_index :motor_audits, %i[auditable_type auditable_id version], name: 'motor_auditable_index',
                                                                      length: { auditable_type: 255 }
    add_index :motor_audits, %i[associated_type associated_id], name: 'motor_auditable_associated_index',
                                                                length: { associated_type: 255 }
    add_index :motor_audits, %i[user_id user_type], name: 'motor_auditable_user_index',
                                                    length: { user_type: 255 }
    add_index :motor_audits, :request_uuid, length: { request_uuid: 255 }
    add_index :motor_audits, :created_at
  end

  def self.down
    drop_table :motor_audits
    drop_table :motor_alert_locks
    drop_table :motor_alerts
    drop_table :motor_taggable_tags
    drop_table :motor_tags
    drop_table :motor_resources
    drop_table :motor_configs
    drop_table :motor_queries
    drop_table :motor_dashboards
  end
end
