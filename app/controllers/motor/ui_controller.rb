# frozen_string_literal: true

module Motor
  class UiController < ApplicationController
    layout 'motor/application'

    helper_method :current_user

    def index
      render_ui
    end

    def new
      render_ui
    end

    def show
      render_ui
    end

    private

    def render_ui
      Motor.reload! if Motor.development?

      Motor::Configs::SyncFromFile.call

      render :show
    end
  end
end
