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
          responses << (bytes.shift | bytes.shift << 8)
        end
        new(responses)
      end

      def encode
        responses.map { |id| [ id & 0xff, id >> 8 ] }.flatten
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
