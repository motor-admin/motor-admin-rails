# frozen_string_literal: true

module Motor
  module Notes
    module NotifyReminder
      NOTIFICATION_DESCRIPTION_LIMIT = 100

      module_function

      def call(reminder)
        notification = find_or_build_notification(reminder)

        return if notification.persisted?

        notification.save!

        Motor::NotificationsMailer.notify_reminder_email(notification).deliver_later!
        Motor::NotificationsChannel.broadcast_to(reminder.recipient,
                                                 ['notify', notification.as_json(include: %i[record])])
      end

      def find_or_build_notification(reminder)
        notification = reminder.notifications.take

        return notification if notification

        note = reminder.record

        Motor::Notification.new(
          title: build_notification_title(note),
          description: note.body.truncate(NOTIFICATION_DESCRIPTION_LIMIT),
          recipient: reminder.recipient,
          record: reminder
        )
      end

      def build_notification_title(note)
        configs = Motor::BuildSchema.for_model(note.record.class)

        display_value = note.record.attributes[configs['display_column']]

        I18n.t('motor.new_reminder_for',
               resource: ["#{configs['display_name'].singularize} ##{note.record[note.record.class.primary_key]}",
                          display_value].join(' '))
      end
    end
  end
end
