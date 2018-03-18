require_relative '../../utils'
require_relative 'frame_control_field'

module Zigbee
  module ZCL
    class Header
      include ArrayUtils

      attr_reader :frame_control, :manufacturer_code, :transaction_sequence_number, :command_identifier

      def initialize(frame_control, sequence_number, command, manufacturer_code = nil)
        unless frame_control.is_a?FrameControlField
          frame_control = FrameControlField.decode([frame_control])
        end
        @frame_control = frame_control
        @manufacturer_code = manufacturer_code
        @transaction_sequence_number = sequence_number
        @command_identifier = command
      end

      def self.decode(bytes)
        frame_control = FrameControlField.decode(bytes)
        manufacturer_code = nil
        if frame_control.manufacturer_specific == 1
          ensure_has_bytes(bytes, 2)
          manufacturer_code = bytes.shift << 8 | bytes.shift
        end
        ensure_has_bytes(bytes, 2)
        transaction_sequence_number = bytes.shift
        command_identifier = bytes.shift
        new(frame_control, transaction_sequence_number, command_identifier, manufacturer_code)
      end

      def encode
        ret = [ frame_control.encode ]
        ret << [ (manufacturer_code >> 8), (manufacturer_code & 0xff) ] if frame_control.manufacturer_specific == 1
        ret << [ transaction_sequence_number, command_identifier ]
        ret.flatten
      end

      class Builder
        def initialize
          @frame_control = 0
          @manufacturer_code = nil
          @transaction_sequence_number = 0
          @command_identifier = nil
        end

        def frame_control(value)
          @frame_control = value
          self
        end

        def manufacturer_code(value)
          @manufacturer_code = value
          self
        end

        def transaction_sequence_number(value)
          @transaction_sequence_number = value
          self
        end

        def command_identifier(value)
          @command_identifier = value
          self
        end

        def build
          Header.new(@frame_control, @transaction_sequence_number, @command_identifier, @manufacturer_code)
        end
      end
    end
  end
end
