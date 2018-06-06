require_relative '../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class ActiveEndpointsResponse < ZDOCommand
      include Zigbee::ArrayUtils

      attr_reader :status, :address, :endpoints

      def initialize(status, address, endpoints)
        @status = status
        @address = address
        @endpoints = endpoints
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 4)
        status = decode_uint8(bytes)
        address = decode_uint16(bytes)
        count = decode_uint8(bytes)
        ensure_has_bytes(bytes, count)
        endpoints = decode_uint8(bytes, count)
        new(status, address, endpoints)
      end

      def encode
        [
            encode_uint8(status),
            encode_uint16(address),
            encode_uint8(endpoints.count),
            encode_uint8(*endpoints)
        ].flatten
      end
    end
  end
end
