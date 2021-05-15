# frozen_string_literal: true

module Motor
  class UiController < ApplicationController
    layout 'motor/application'

    def index
      Motor.reload! if Motor.development?

      Motor::Configs::SyncFromFile.call

      render :show
    end

    def show
      Motor.reload! if Motor.development?

      Motor::Configs::SyncFromFile.call

      render :show
    end
  end
end
