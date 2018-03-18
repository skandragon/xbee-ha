require_relative '../../utils'

module Zigbee
  module ZCL
    class ReadAttributes
      include ArrayUtils

      attr_reader :attribute_ids

      def initialize(attribute_ids)
        @attribute_ids = Array(attribute_ids)
      end

      def self.decode(bytes)
        attribute_ids = []
        while bytes.length > 0
          ensure_has_bytes(bytes, 2)
          attribute_ids << ((bytes.shift << 8) | bytes.shift)
        end
        new(attribute_ids)
      end

      def encode
        attribute_ids.map { |id| [ id >> 8, id & 0xff ] }.flatten
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
          ReadAttributes.new(@attribute_ids)
        end
      end
    end
  end
end
