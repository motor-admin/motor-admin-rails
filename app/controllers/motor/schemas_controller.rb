# frozen_string_literal: true

module Motor
  class SchemasController < ActionController::API
    def show
      render json: Motor::Schema.load
    end

    def update; end
  end
end
