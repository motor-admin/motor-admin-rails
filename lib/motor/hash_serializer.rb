# frozen_string_literal: true

module Motor
  class HashSerializer
    def self.dump(hash)
      hash.to_json
    end

    def self.load(hash)
      hash = JSON.parse(hash.presence || '{}') if hash.is_a?(String)

      (hash || {}).with_indifferent_access
    end
  end
end
