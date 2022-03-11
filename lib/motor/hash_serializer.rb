# frozen_string_literal: true

module Motor
  class HashSerializer
    def self.dump(hash)
      hash.to_json
    end

    def self.load(hash)
      return hash unless hash

      hash = JSON.parse(hash.presence || '{}') if hash.is_a?(String)

      if hash.is_a?(Hash)
        hash.with_indifferent_access
      else
        hash.is_a?(FalseClass) ? hash : hash || {}
      end
    end
  end
end
