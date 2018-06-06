require_relative '../utils'
require_relative './data_type'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class WriteAttributesResponse < ZCLCommand
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

      class Builder
        def initialize
          @responses = []
        end

        def responses(list)
          @responses = list
          self
        end

        def build
          WriteAttributesResponse.new(@responses)
        end
      end

      class Response
        include ArrayUtils

        attr_reader :id, :status

        def initialize(id, status)
          @id = id
          @status = status
        end

        def encode
          ret = [ status, id & 0xff, id >> 8 ]
          ret.flatten
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, 3)
          status = decode_uint8(bytes)
          attribute = decode_uint16(bytes)
          new(attribute, status)
        end
      end
    end
  end
end
