# frozen_string_literal: true

module Motor
  class NotesController < ApiBaseController
    wrap_parameters :data, except: %i[include fields]

    load_and_authorize_resource :note, only: %i[index show update destroy]
    before_action :build_note, only: :create
    authorize_resource :note, only: :create

    def index
      @notes = Motor::ApiQuery.call(@notes.active.order(created_at: :asc), params)

      render json: { data: Motor::ApiQuery::BuildJson.call(@notes, params, current_ability) }
    end

    def show
      render json: { data: Motor::ApiQuery::BuildJson.call(@note, params, current_ability) }
    end

    def create
      Motor::Notes::Persist.call(@note, current_user)
      Motor::NotifyNoteMentionsJob.perform_later(@note, current_user)

      render json: { data: Motor::ApiQuery::BuildJson.call(@note, params, current_ability) }
    end

    def update
      @note.assign_attributes(note_params)

      Motor::Notes::Persist.call(@note, current_user)
      Motor::NotifyNoteMentionsJob.perform_later(@note, current_user)

      render json: { data: Motor::ApiQuery::BuildJson.call(@note, params, current_ability) }
    end

    def destroy
      @note.update!(deleted_at: Time.current)

      Motor::NotesChannel.broadcast_to(
        @note.values_at(:record_type, :record_id).join(':'),
        ['remove', @note.as_json(only: %i[id body created_at updated_at])]
      )

      head :ok
    end

    private

    def build_note
      @note = Motor::Note.new(note_params.merge(author: current_user))
    end

    def note_params
      params.require(:data).permit(:body, :record_id, :record_type)
    end
  end
end
