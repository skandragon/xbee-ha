require_relative '../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class SimpleDescriptorResponse < ZDOCommand
      include Zigbee::ArrayUtils

      attr_reader :status, :address, :endpoint, :profile, :device_id,
                  :device_version, :input_clusters, :output_clusters

      def initialize(status, address, endpoint, profile, device_id, device_version, input_clusters, output_clusters)
        @status = status
        @address = address
        @endpoint = endpoint
        @profile = profile
        @device_id = device_id
        @device_version = device_version
        @input_clusters = input_clusters
        @output_clusters = output_clusters
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 4)
        status = decode_uint8(bytes)
        address = decode_uint16(bytes)
        length = decode_uint8(bytes)
        ensure_has_bytes(bytes, length)

        dbytes = decode_uint8(bytes, length)
        ensure_has_bytes(dbytes, 7)
        endpoint = decode_uint8(dbytes)
        profile = decode_uint16(dbytes)
        device_id = decode_uint16(dbytes)
        device_version = decode_uint8(dbytes) & 0x0f

        count = decode_uint8(dbytes)
        ensure_has_bytes(dbytes, count * 2)
        input_clusters = decode_uint16(dbytes, count)
        ensure_has_bytes(dbytes, 1)
        count = decode_uint8(dbytes)
        ensure_has_bytes(dbytes, count * 2)
        output_clusters = decode_uint16(dbytes, count)
        # if any bytes remain, ignore them.  I think this is for future expansion.

        new(status, address, endpoint, profile, device_id, device_version, input_clusters, output_clusters)
      end

      def encode
        dbytes = [
            encode_uint8(endpoint),
            encode_uint16(profile),
            encode_uint16(device_id),
            encode_uint8(device_version & 0x0f),
            encode_uint8(input_clusters.count),
            encode_uint16(*input_clusters),
            encode_uint8(output_clusters.count),
            encode_uint16(*output_clusters)
        ].flatten

        [
            encode_uint8(status),
            encode_uint16(address),
            encode_uint8(dbytes.length),
            encode_uint8(*dbytes)
        ].flatten
      end
    end
  end
end
