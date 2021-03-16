# frozen_string_literal: true

module Motor
  class UiController < ApplicationController
    layout 'motor/application'

    before_action :assign_data

    def index
      Motor.reload! if Motor.development?

      render :show
    end

    def show
      Motor.reload! if Motor.development?

      render :show
    end

    private

    def assign_data
      @data = {
        base_path: Motor::Admin.routes.url_helpers.motor_path,
        schema: Motor::BuildSchema.call
      }
    end
  end
end
