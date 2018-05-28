require_relative '../../utils'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class DefaultResponse < ZCLCommand
      include ArrayUtils

      attr_reader :command, :status

      def initialize(command, status)
        @command = command
        @status = status
      end

      def self.parse(bytes)
        ensure_has_bytes(bytes, 2)
        command = bytes.shift
        status = bytes.shift
        new(command, status)
      end

      def encode
        [ command, status ]
      end
    end
  end
end
