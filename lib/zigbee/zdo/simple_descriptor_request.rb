require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class SimpleDescriptorRequest < ZDOCommand
      include ArrayUtils

      attr_reader :address, :endpoint

      def initialize(address, endpoint)
        @address = address
        @endpoint = endpoint
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 3)
        address = bytes.shift | bytes.shift << 8
        endpoint = bytes.shift
        new(address, endpoint)
      end

      def encode
        [
            address & 0xff, address >> 8,
            endpoint
        ]
      end
    end
  end
end
