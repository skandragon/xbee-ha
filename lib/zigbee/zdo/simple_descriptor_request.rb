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
        address = decode_uint16(bytes)
        endpoint = decode_uint8(bytes)
        new(address, endpoint)
      end

      def encode
        [
            encode_uint16(address),
            encode_uint8(endpoint)
        ].flatten
      end
    end
  end
end
