# frozen_string_literal: true

module Motor
  class NotificationsMailer < ApplicationMailer
    def notify_mention_email(notification)
      @notification = notification

      @note = notification.record

      subject =
        "#{@note.author&.email || 'Anonymous'} mentioned you in " \
        "#{@note.record.class.model_name.human} ##{@note.record.id}"

      mail(
        from: from_address,
        to: notification.recipient.email,
        subject: subject
      )
    end

    def notify_reminder_email(notification)
      @notification = notification

      @note = notification.record.record

      mail(
        from: from_address,
        to: notification.recipient.email,
        subject: "Reminder for #{@note.record.class.model_name.human} ##{@note.record.id}"
      )
    end
  end
end
