# frozen_string_literal: true

module Motor
  class RemindersController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :reminder

    def create
      @reminder.update!(author: current_user, recipient: current_user)

      broadcast_note_update(@reminder.record)

      render json: { data: Motor::ApiQuery::BuildJson.call(@reminder, params, current_ability) }
    end

    def destroy
      @reminder.destroy!

      broadcast_note_update(@reminder.record)

      head :ok
    end

    private

    def broadcast_note_update(note)
      Motor::NotesChannel.broadcast_to(
        note.values_at(:record_type, :record_id).join(':'),
        ['update', note.as_json(include: %i[author tags reminders])]
      )
    end

    def reminder_params
      params.require(:data).permit(:record_id, :record_type, :scheduled_at)
    end
  end
end
