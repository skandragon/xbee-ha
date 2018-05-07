require_relative '../../utils'

module Zigbee
  module ZCL
    class ReadAttributesResponse
      include ArrayUtils

      attr_reader :attribute_ids

      def initialize(attribute_ids)
        @attribute_ids = Array(attribute_ids)
      end

      def self.decode(bytes)
        attribute_ids = []
        while bytes.length > 0
          ensure_has_bytes(bytes, 2)
          attribute_ids << (bytes.shift | bytes.shift << 8)
        end
        new(attribute_ids)
      end

      def encode
        attribute_ids.map { |id| [ id & 0xff, id >> 8 ] }.flatten
      end

      class Builder
        def initialize
          @attribute_ids = []
        end

        def attribute_ids(value)
          @attribute_ids = value
          self
        end

        def build
          ReadAttributesResponse.new(@attribute_ids)
        end
      end
    end
  end
end
