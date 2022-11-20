# frozen_string_literal: true

module Motor
  class DummyChannel
    def self.broadcast_to(*_args)
      nil
    end
  end

  module ApplicationCable
    class Channel < defined?(ActionCable) ? ActionCable::Channel::Base : Motor::DummyChannel
    end
  end
end
