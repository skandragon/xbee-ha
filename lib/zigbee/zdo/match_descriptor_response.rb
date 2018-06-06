require_relative '../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class MatchDescriptorResponse < ZDOCommand
      include ArrayUtils

      attr_reader :status
      attr_reader :address
      attr_reader :endpoints

      def initialize(status, address, endpoints)
        @status = status
        @address = address
        @endpoints = endpoints
      end

      def encode
        [
            encode_uint8(status),
            encode_uint16(address),
            encode_uint8(endpoints.count),
            encode_uint8(*endpoints)
        ].flatten
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 4)
        status = decode_uint8(bytes)
        address = decode_uint16(bytes)
        n = decode_uint8(bytes)
        ensure_has_bytes(bytes, n)
        endpoints = decode_uint8(bytes, n)
        new(status, address, endpoints)
      end
    end
  end
end
