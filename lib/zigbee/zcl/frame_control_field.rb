module Zigbee
  module ZCL
    class FrameControlField
      attr_reader :frame_type, :manufacturer_specific, :direction, :disable_default_response

      FRAME_TYPE_GLOBAL = 0x00
      FRAME_TYPE_LOCAL  = 0x01

      def initialize(frame_type, direction, disable_default_response = 0, manufacturer_specific = 0)
        @frame_type = frame_type
        @manufacturer_specific = manufacturer_specific
        @direction = direction
        @disable_default_response = disable_default_response
      end

      def value
        ret = (frame_type & 0x03)
        ret |= ((manufacturer_specific & 0x01) << 2)
        ret |= ((direction & 0x01) << 3)
        ret |= ((disable_default_response & 0x01) << 4)
      end

      def encode
        value.char
      end

      def self.decode(data)
        byte = data.unpack('C')
        new(byte & 0x03, ((byte >> 2) & 0x01), ((byte >> 3) & 0x01), ((byte >> 4) & 0x01))
      end

      def self.has_manufacturer_flag(value)
        (value & 0x04) != 0
      end
    end
  end
end
