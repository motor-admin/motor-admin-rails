require_relative './schema/load_from_rails'
require_relative './schema/utils'

module Motor
  module Schema
    module_function

    def load
      LoadFromRails.call
    end
  end
end
