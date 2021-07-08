# frozen_string_literal: true

class NotesController < ApplicationController
  load_and_authorize_resource :note

  def create
    @note.save!

    head :ok
  rescue StandardError => e
    render json: { errors: [e.message] }, status: :internal_server_error
  end

  private

  def note_params
    params.permit(:record_type, :record_id, :body, images: [%i[filename io]]).tap do |attrs|
      attrs[:images].each do |img|
        img[:io] = StringIO.new(img[:io].encode('ISO-8859-1'))
      end
    end
  end
end
