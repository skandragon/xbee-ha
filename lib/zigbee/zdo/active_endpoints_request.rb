require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class ActiveEndpointsRequest < ZDOCommand
      include ArrayUtils

      attr_reader :address

      def initialize(address)
        @address = address
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 2)
        address = bytes.shift | bytes.shift << 8
        new(address)
      end

      def encode
        [ address & 0xff, address >> 8 ]
      end
    end
  end
end
