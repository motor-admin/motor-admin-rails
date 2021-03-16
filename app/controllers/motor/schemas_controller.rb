# frozen_string_literal: true

module Motor
  class SchemasController < ActionController::API
    def show
      render json: Motor::BuildSchema.call
    end

    def update; end
  end
end
