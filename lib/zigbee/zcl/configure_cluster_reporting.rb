require_relative '../utils'
require_relative './data_type'
require_relative './zcl_command'

module Zigbee
  module ZCL
    class ConfigureClusterReporting < ZCLCommand
      include ArrayUtils

      attr_reader :records

      def initialize(records)
        @records = records
      end

      def self.decode(bytes)
        records = []
        while bytes.length > 0
          records << Record.decode(bytes)
        end
        new(records)
      end

      def encode
        records.map { |record| record.encode }.flatten
      end

      class Record
        include ArrayUtils

        attr_reader :direction, :attribute, :data_type, :minimum, :maximum, :reportable_change, :timeout

        def initialize(direction, attribute, data_type, minimum, maximum, reportable_change, timeout)
          @direction = direction
          @attribute = attribute
          @data_type = data_type
          @minimum = minimum
          @maximum = maximum
          @reportable_change = reportable_change
          @timeout = timeout
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, 3)
          direction = decode_uint8(bytes)
          attribute = decode_uint16(bytes)
          if direction == 0x00
            ensure_has_bytes(bytes, 5)
            data_type = decode_uint8(bytes)
            minimum = decode_uint16(bytes)
            maximum = decode_uint16(bytes)
            data_class = Zigbee::ZCL::DataType.class_for(data_type)
            raise ArgumentError.new("Unknown class for data type 0x%02x" % data_type) unless data_class
            data = data_class.decode_data(bytes)
            value = nil
            if data.respond_to?(:value)
              value = data.value
            end
            new(direction, attribute, data_type, minimum, maximum, value, nil)
          else
            ensure_has_bytes(bytes, 2)
            timeout = decode_uint16(bytes)
            new(direction, attribute, nil, nil, nil, nil, timeout)
          end
        end

        def encode
          if direction == 0
            data_class = Zigbee::ZCL::DataType.class_for(data_type)
            item = data_class.new(reportable_change)
            [
                encode_uint8(direction),
                encode_uint16(attribute),
                encode_uint8(data_type),
                encode_uint16(minimum),
                encode_uint16(maximum),
                item.encode_data
            ].flatten
          else
            [
                encode_uint8(direction),
                encode_uint16(attribute),
                encode_uint16(timeout)
            ].flatten
          end
        end
      end
    end
  end
end
