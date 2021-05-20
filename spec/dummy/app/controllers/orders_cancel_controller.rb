# frozen_string_literal: true

class OrdersCancelController < ApplicationController
  wrap_parameters :data
  load_and_authorize_resource :order, parent: true

  def create
    ApplicationRecord.transaction do
      @order.update!(status: :canceled)
      @order.notes.create!(body: params.dig(:data, :reason))
    end

    head :ok
  rescue StandardError => e
    render json: { errors: [e.message] }, status: :internal_server_error
  end
end
