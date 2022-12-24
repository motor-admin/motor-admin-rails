# frozen_string_literal: true

module Motor
  module Notes
    module NotifyMentions
      EMAIL_REGEXP =
        /[a-z0-9][.']?(?:(?:[a-z0-9_-]++[.'])*[a-z0-9_-]++)*@(?:[a-z0-9]++[.-])*[a-z0-9]++\.[a-z]{2,}/i.freeze
      NOTIFICATION_DESCRIPTION_LIMIT = 100

      module_function

      def call(note, current_user)
        users_class = fetch_users_class(current_user)

        return unless users_class

        emails  = note.body.scan(EMAIL_REGEXP)
        emails -= [current_user&.email]

        users_class.where(email: emails).each do |user|
          notification = find_or_build_notification(note, user, current_user)

          next if notification.persisted?

          notification.save!

          Motor::NotificationsMailer.notify_mention_email(notification).deliver_later!
          Motor::NotificationsChannel.broadcast_to(user, ['notify', notification.as_json(include: %i[record])])
        end
      end

      def find_or_build_notification(note, user, current_user)
        notification = note.notifications.find { |e| e.recipient_id == user.id && e.recipient_type == user.class.name }

        return notification if notification

        Motor::Notification.new(
          title: build_mention_title(note),
          description: build_mention_description(note, current_user),
          recipient: user,
          record: note
        )
      end

      def build_mention_title(note)
        configs = Motor::BuildSchema.for_model(note.record.class)

        display_value = note.record.attributes[configs['display_column']]

        I18n.t('motor.new_mention_for',
               resource: ["#{configs['display_name'].singularize} ##{note.record[note.record.class.primary_key]}",
                          display_value].join(' '))
      end

      def build_mention_description(note, current_user)
        I18n.t('motor.user_mentioned_you_with_note',
               user: current_user&.email || 'Anonymous',
               note: note.body.truncate(NOTIFICATION_DESCRIPTION_LIMIT))
      end

      def fetch_users_class(current_user)
        return current_user.class if current_user
        return Motor::AdminUser if defined?(Motor::AdminUser)
        return AdminUser if defined?(AdminUser)
        return User if defined?(User)

        nil
      end
    end
  end
end
