require_relative '../../utils'
require_relative './data_type'

module Zigbee
  module ZCL
    class ReadAttributesResponse
      include ArrayUtils

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

      class Builder
        def initialize
          @responses = []
        end

        def responses(list)
          @responses = list
          self
        end

        def build
          ReadAttributesResponse.new(@responses)
        end
      end

      class Response
        include ArrayUtils

        attr_reader :id, :status, :data_type, :value

        def initialize(id, status, data_type, value)
          @id = id
          @status = status
          @data_type = data_type
          @value = value
        end

        def encode
          ret = [ id & 0xff, id >> 8, status ]
          if status == 0x00
            ret << data_type
            ret << Zigbee::ZCL::DataType.class_for(data_type).new(value).encode
          end
          ret.flatten
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, 3)
          attribute = (bytes.shift | bytes.shift << 8)
          status = bytes.shift
          if status == 0x00
            ensure_has_bytes(bytes, 1)
            data_type = bytes.shift
            data_class = Zigbee::ZCL::DataType.class_for(data_type).decode(bytes)
            value = nil
            if data_class.respond_to?:value
              value = data_class.value
            end
            new(attribute, status, data_type, value)
          else
            new(attribute, status, nil, nil)
          end
        end
      end
    end
  end
end
