require_relative 'frame_control_field'

module Zigbee
  module ZCL
    class Header
      attr_reader :frame_control, :manufacturer_code, :transaction_sequence_number, :command_identifier

      def initialize(frame_control, sequence_number, command, manufacturer_code = 0)
        if frame_control.is_a?FrameControlField
          frame_control = frame_control.value
        end
        @frame_control = frame_control
        @manufacturer_code = manufacturer_code
        @transaction_sequence_number = sequence_number
        @command_identifier = command
      end

      def encode
        if FrameControlField.has_manufacturer_flag(frame_control)
          [ frame_control, manufacturer_code, transaction_sequence_number, command_identifier ].pack('CS>CC')
        else
          [ frame_control, transaction_sequence_number, command_identifier ].pack('CCC')
        end
      end
    end
  end
end
