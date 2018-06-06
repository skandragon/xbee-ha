require_relative '../utils'
require_relative './data_type'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class ReportAttributes < ZCLCommand
      include Zigbee::ArrayUtils

      attr_reader :responses

      def initialize(responses)
        @responses = Array(responses)
      end

      def self.decode(bytes)
        responses = []
        while bytes.length > 0
          responses << Response.decode(bytes)
        end
        new(responses)
      end

      def encode
        responses.map { |response| response.encode }.flatten
      end

      class Response
        include ArrayUtils

        attr_reader :id, :data_type, :value

        def initialize(id, data_type, value)
          @id = id
          @data_type = data_type
          @value = value
        end

        # TODO: add encoding/decoding for bags, sets, etc.

        def encode
          ret = [ id & 0xff, id >> 8, data_type ]
          ret << Zigbee::ZCL::DataType.class_for(data_type).new(value).encode_data
          ret.flatten
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, 3)
          attribute = decode_uint16(bytes)
          data_type = decode_uint8(bytes)
          data_class = Zigbee::ZCL::DataType.class_for(data_type)
          raise ArgumentError.new("Unknown class for data type 0x%02x" % data_type) unless data_class
          data = data_class.decode_data(bytes)
          value = nil
          if data.respond_to?(:value)
            value = data.value
          end
          new(attribute, data_type, value)
        end
      end
    end
  end
end
