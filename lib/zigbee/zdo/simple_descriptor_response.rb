require_relative '../../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class SimpleDescriptorResponse < ZDOCommand
      include ArrayUtils

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
        status = bytes.shift
        address = bytes.shift | bytes.shift << 8
        length = bytes.shift
        ensure_has_bytes(bytes, length)

        dbytes = length.times.map { bytes.shift }
        ensure_has_bytes(dbytes, 7)
        endpoint = dbytes.shift
        profile = dbytes.shift | dbytes.shift << 8
        device_id = dbytes.shift | dbytes.shift << 8
        device_version = dbytes.shift & 0x0f

        count = dbytes.shift
        ensure_has_bytes(dbytes, count * 2)
        input_clusters = count.times.map { dbytes.shift | dbytes.shift << 8 }
        ensure_has_bytes(dbytes, 1)
        count = dbytes.shift
        ensure_has_bytes(dbytes, count * 2)
        output_clusters = count.times.map { dbytes.shift | dbytes.shift << 8 }
        # if any bytes remain, ignore them.  I think this is for future expansion.

        new(status, address, endpoint, profile, device_id, device_version, input_clusters, output_clusters)
      end

      def encode
        dbytes = [
            endpoint,
            profile & 0xff, profile >> 8,
            device_id & 0xff, device_id >> 8,
            device_version & 0x0f,
            input_clusters.count,
            input_clusters.map { |c| [ c & 0xff, c >> 8 ] },
            output_clusters.count,
            output_clusters.map { |c| [ c & 0xff, c >> 8 ] }
        ]

        [
            status,
            address & 0xff, address >> 8,
            dbytes.length,
            dbytes
        ].flatten
      end
    end
  end
end
