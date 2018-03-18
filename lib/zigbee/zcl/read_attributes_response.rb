require_relative '../../utils'

module Zigbee
  module ZCL
    class ReadAttributesResponse
      include ArrayUtils

      attr_reader :responses

      def initialize(responses)
        @responses = Array(responses)
      end

      def self.decode(bytes)
        responses = []
        while bytes.length > 0
          ensure_has_bytes(bytes, 2)
          responses << ((bytes.shift << 8) | bytes.shift)
        end
        new(responses)
      end

      def encode
        responses.map { |id| [ id >> 8, id & 0xff ] }.flatten
      end

      class Builder
        def initialize
          @responses = []
        end

        def responses(value)
          @responses = value
          self
        end

        def build
          ReadAttributesResponse.new(@responses)
        end
      end
    end
  end
end
