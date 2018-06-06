require_relative '../utils'
require_relative './data_type'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class WriteAttributes < ZCLCommand
      include Zigbee::ArrayUtils

      attr_reader :requests

      def initialize(requests)
        @requests = Array(requests)
      end

      def self.decode(bytes)
        requests = []
        while bytes.length > 0
          requests << Request.decode(bytes)
        end
        new(requests)
      end

      def encode
        requests.map { |request| request.encode }.flatten
      end

      class Builder
        def initialize
          @requests = []
        end

        def requests(list)
          @requests = list
          self
        end

        def build
          WriteAttributes.new(@requests)
        end
      end

      class Request
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
          ensure_has_bytes(bytes, 1)
          data_type = decode_uint8(bytes)
          data_class = Zigbee::ZCL::DataType.class_for(data_type).decode_data(bytes)
          value = nil
          if data_class.respond_to?(:value)
            value = data_class.value
          end
          new(attribute, data_type, value)
        end
      end
    end

    class WriteAttributesNoResponse < WriteAttributes
    end

    class WriteAttributesUndivided < WriteAttributes
    end
  end
end
