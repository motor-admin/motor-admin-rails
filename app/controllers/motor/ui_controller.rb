# frozen_string_literal: true

module Motor
  class UiController < ApplicationController
    layout 'motor/application'

    def show
      Motor.reload! if Motor.development?

      @data = {
        base_path: Motor::Admin.routes.url_helpers.motor_path,
        schema: Motor::Schema.load
      }
    end
  end
end
