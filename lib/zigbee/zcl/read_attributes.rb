require_relative '../utils'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class ReadAttributes < ZCLCommand
      include Zigbee::ArrayUtils

      attr_reader :attribute_ids

      def initialize(attribute_ids)
        @attribute_ids = Array(attribute_ids)
      end

      def self.decode(bytes)
        attribute_ids = []
        while bytes.length > 0
          ensure_has_bytes(bytes, 2)
          attribute_ids << decode_uint16(bytes)
        end
        new(attribute_ids)
      end

      def encode
        encode_uint16(*attribute_ids)
      end
    end
  end
end
