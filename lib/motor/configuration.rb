# frozen_string_literal: true

module Motor
  # Configuration class for Motor customizations
  class Configuration
    # Method used to define the current_user implementation
    # @return [Proc] a lambda that returns the current user
    attr_accessor :current_user_method
    
    # Controls whether models are visible by default in the admin interface
    # @return [Boolean] true if models should be visible by default
    attr_accessor :models_visible_by_default

    def initialize
      # Default to nil - will use the original implementation
      @current_user_method = nil
      
      # Default to true - models are visible by default
      @models_visible_by_default = true
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration) if block_given?
    end
  end
end
