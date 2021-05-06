# frozen_string_literal: true

module Motor
  module WrapIoParams
    extend ActiveSupport::Concern

    included do
      before_action :wrap_io_params, only: %i[update create]
    end

    private

    def wrap_io_params(hash = params)
      hash.each do |key, value|
        if key == 'io'
          hash[key] = StringIO.new(value.encode('ISO-8859-1'))
        elsif value.is_a?(ActionController::Parameters)
          wrap_io_params(value)
        end
      end

      hash
    end
  end
end
