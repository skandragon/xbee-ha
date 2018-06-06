require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class DeviceAnnounce < ZDOCommand
      include ArrayUtils

      attr_reader :address, :ieee, :capability

      def initialize(address, ieee, capability)
        @address = address
        @ieee = ieee
        @capability = capability
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 11)
        address = decode_uint16(bytes)
        ieee = decode_uint64(bytes)
        capability = decode_uint8(bytes)
        new(address, ieee, capability)
      end

      def encode
        [ encode_uint16(address), encode_uint64(ieee), encode_uint8(capability) ].flatten
      end
    end
  end
end
