module Motor
  class UiController < ActionController::Base
    layout 'motor/application'

    def show
      @data = {
        base_path: Motor::Admin.routes.url_helpers.motor_path
      }
    end
  end
end
