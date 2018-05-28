require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class ActiveEndpointsResponse < ZDOCommand
      include ArrayUtils

      attr_reader :status, :address, :endpoints

      def initialize(status, address, endpoints)
        @status = status
        @address = address
        @endpoints = endpoints
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 4)
        status = bytes.shift
        address = bytes.shift | bytes.shift << 8
        count = bytes.shift
        ensure_has_bytes(bytes, count)
        endpoints = count.times.map { bytes.shift }
        new(status, address, endpoints)
      end

      def encode
        [
            status,
            address & 0xff, address >> 8,
            endpoints.count,
            endpoints
        ].flatten
      end
    end
  end
end
