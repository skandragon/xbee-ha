require_relative '../../utils'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class MatchDescriptorRequest < ZCLCommand
      include ArrayUtils

      attr_reader :address
      attr_reader :profile_id
      attr_reader :input_clusters
      attr_reader :output_clusters

      def initialize(address, profile_id, input_clusters, output_clusters)
        @address = address
        @profile_id = profile_id
        @input_clusters = input_clusters
        @output_clusters = output_clusters
      end

      def encode
        ret = [
            address & 0xff, address >> 8,
            profile_id & 0xff, profile_id >> 8,
            input_clusters.count,
            input_clusters.map { |x| [x & 0xff, x >> 8 ]},
            output_clusters.count,
            output_clusters.map { |x| [x & 0xff, x >> 8 ]},
        ].flatten
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 5)
        address = bytes.shift | (bytes.shift << 8)
        profile_id = bytes.shift | (bytes.shift << 8)
        n = bytes.shift
        input_clusters = n.times.map {
          ensure_has_bytes(bytes, 2)
          bytes.shift | (bytes.shift << 8)
        }
        ensure_has_bytes(bytes, 1)
        n = bytes.shift
        output_clusters = n.times.map {
          ensure_has_bytes(bytes, 2)
          bytes.shift | (bytes.shift << 8)
        }
        new(address, profile_id, input_clusters, output_clusters)
      end
    end
  end
end
