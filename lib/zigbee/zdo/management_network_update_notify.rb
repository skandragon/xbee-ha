require_relative '../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class ManagementNetworkUpdateNotify < ZDOCommand
      include Zigbee::ArrayUtils

      attr_reader :status, :scanned_channels, :transmissions, :failed_transmissions, :energy

      def initialize(status, scanned_channels, transmissions, failed_transmissions, energy)
        @status = status
        @scanned_channels = scanned_channels
        @transmissions = transmissions
        @failed_transmissions = failed_transmissions
        @energy = energy
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 10)
        status = decode_uint8(bytes)
        scanned_channels = decode_uint32(bytes)
        transmissions = decode_uint16(bytes)
        failed_transmissions = decode_uint16(bytes)
        length = decode_uint8(bytes)
        ensure_has_bytes(bytes, length)
        energy = decode_uint8(bytes, length)
        new(status, scanned_channels, transmissions, failed_transmissions, energy)
      end

      def encode
        [
            encode_uint8(status),
            encode_uint32(scanned_channels),
            encode_uint16(transmissions),
            encode_uint16(failed_transmissions),
            energy.length,
            encode_uint8(*energy)
        ].flatten
      end
    end
  end
end
