require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class DescriptorRequest < ZDOCommand
      include ArrayUtils

      attr_reader :address

      def initialize(address)
        @address = address
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 2)
        address = decode_uint16(bytes)
        new(address)
      end

      def encode
        encode_uint16(address)
      end
    end
  end
end
