require_relative '../utils'
require_relative './zdo_command'

module Zigbee
  module ZDO
    class MatchDescriptorRequest < ZDOCommand
      include Zigbee::ArrayUtils

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

      def self.decode(bytes)
        ensure_has_bytes(bytes, 5)
        address = decode_uint16(bytes)
        profile_id = decode_uint16(bytes)
        n = decode_uint8(bytes)
        ensure_has_bytes(bytes, n * 2)
        input_clusters = decode_uint16(bytes, n)
        ensure_has_bytes(bytes, 1)
        n = decode_uint8(bytes)
        ensure_has_bytes(bytes, n * 2)
        output_clusters = decode_uint16(bytes, n)
        new(address, profile_id, input_clusters, output_clusters)
      end

      def encode
        ret = [
            encode_uint16(address, profile_id),
            encode_uint8(input_clusters.count),
            encode_uint16(*input_clusters),
            encode_uint8(output_clusters.count),
            encode_uint16(*output_clusters)
        ].flatten
      end
    end
  end
end
