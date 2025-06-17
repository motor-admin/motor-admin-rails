# frozen_string_literal: true

# Example Motor configuration
Rails.application.config.to_prepare do
  Motor.configure do |config|
    # Configure whether models are visible by default in the admin UI
    # Set to false if you want to hide models by default
    # config.models_visible_by_default = false

    # Define a custom current_user method implementation if needed
    # Example using Warden (commonly used by Devise and other authentication systems):
    # config.current_user_method = -> do
    #   @current_user ||= begin
    #     warden = request.env['warden']
    #     if warden && warden.user
    #       warden.user
    #     end
    #   end
    # end
  end
end
