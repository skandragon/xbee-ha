require_relative '../utils'

module Zigbee
  module ZCL
    class FrameControlField
      include Zigbee::ArrayUtils

      attr_reader :frame_type, :manufacturer_specific, :direction, :disable_default_response

      FRAME_TYPE_GLOBAL = 0x00
      FRAME_TYPE_LOCAL  = 0x01

      def initialize(frame_type, direction, disable_default_response, manufacturer_specific)
        @frame_type = frame_type & 0x03
        @manufacturer_specific = manufacturer_specific & 0x01
        @direction = direction & 0x01
        @disable_default_response = disable_default_response & 0x01
      end

      def encode
        ret = (frame_type & 0x03)
        ret |= ((manufacturer_specific & 0x01) << 2)
        ret |= ((direction & 0x01) << 3)
        ret |= ((disable_default_response & 0x01) << 4)
        [ ret ]
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 1)
        byte = decode_uint8(bytes)
        new(byte & 0x03, ((byte >> 3) & 0x01), ((byte >> 4) & 0x01), ((byte >> 2) & 0x01))
      end

      class Builder
        def initialize
          @frame_type = FRAME_TYPE_GLOBAL
          @direction = 0
          @disable_default_response = 0
          @manufacturer_specific = 0
        end

        def frame_type(value)
          @frame_type = value
          self
        end

        def direction(value)
          @direction = value
          self
        end

        def disable_default_response(value)
          @disable_default_response = value
          self
        end

        def manufacturer_specific(value)
          @manufacturer_specific = value
          self
        end

        def build
          FrameControlField.new(@frame_type, @direction, @disable_default_response, @manufacturer_specific)
        end
      end
    end
  end
end
