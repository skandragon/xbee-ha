require_relative '../../utils'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class MatchDescriptorResponse < ZCLCommand
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
            status,
            address & 0xff, address >> 8,
            endpoints.count,
            endpoints
        ].flatten
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 4)
        status = bytes.shift
        address = bytes.shift | (bytes.shift << 8)
        n = bytes.shift
        endpoints = n.times.map {
          ensure_has_bytes(bytes, 1)
          bytes.shift
        }
        new(status, address, endpoints)
      end
    end
  end
end
