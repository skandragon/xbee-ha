require_relative '../utils'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class DefaultResponse < ZCLCommand
      include Zigbee::ArrayUtils

      attr_reader :command, :status

      def initialize(command, status)
        @command = command
        @status = status
      end

      def self.decode(bytes)
        ensure_has_bytes(bytes, 2)
        command = decode_uint8(bytes)
        status = decode_uint8(bytes)
        new(command, status)
      end

      def encode
        [ command, status ]
      end
    end
  end
end
