require_relative '../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class DeviceAnnounce < ZDOCommand
      include Zigbee::ArrayUtils

      attr_reader :address, :ieee, :capability, :capability_strings

      def initialize(address, ieee, capability)
        @address = address
        @ieee = ieee
        @capability = capability
        cap_strings = []
        cap_strings << 'alternate-pan-controller' if (capability & 0x01) > 0
        cap_strings << 'full-function-device' if (capability & 0x02) > 0
        cap_strings << 'mains-powered' if (capability & 0x04) > 0
        cap_strings << 'receiver-on-when-idle' if (capability & 0x08) > 0
        cap_strings << 'high-security-mode' if (capability & 0x40) > 0
        cap_strings << 'allocate-address' if (capability & 0x80) > 0
        @capability_strings = cap_strings
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
