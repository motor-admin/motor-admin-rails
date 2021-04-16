# frozen_string_literal: true

module Motor
  class UiController < ApplicationController
    layout 'motor/application'

    def index
      Motor.reload! if Motor.development?

      render :show
    end

    def show
      Motor.reload! if Motor.development?

      render :show
    end
  end
end
