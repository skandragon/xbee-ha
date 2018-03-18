require_relative '../../utils'

module Zigbee
  module ZCL
    class DataType
      include ArrayUtils

      attr_reader :type

      def self.decode(bytes)
        type = bytes.shift

        subclasses = ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
        subclass = subclasses.select { |klass| klass.const_get(:TYPE) == type }.first
        if subclass.nil?
          throw ArgumentError.new("Cannot find data type for type 0x#{type.to_s(16)}")
        end
        @type = type
        subclass.decode(bytes)
      end

      def encode
        raise StandardError.new("Invalid data type implementation, needs to define encode")
      end

      class NoData < DataType
        TYPE = 0x00

        def self.decode(_bytes)
          new
        end

        def invalid?
          false
        end
      end

      class Uint8 < DataType
        TYPE = 0x20
        INVALID_VALUE = 0xff

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, 1)
          value = bytes.shift
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint16 < DataType
        TYPE = 0x21
        INVALID_VALUE = 0xffff

        attr_reader :value

        def initialize(value)
          @value = value
        end


        def self.decode(bytes)
          ensure_has_bytes(bytes, 2)
          value = 0
          2.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint24 < DataType
        TYPE = 0x22
        INVALID_VALUE = 0xffffff
        LENGTH = 3

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint32 < DataType
        TYPE = 0x23
        INVALID_VALUE = 0xffffffff
        LENGTH = 4

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint40 < DataType
        TYPE = 0x24
        INVALID_VALUE = 0xffffffffff
        LENGTH = 5

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint48 < DataType
        TYPE = 0x25
        INVALID_VALUE = 0xffffffffffff
        LENGTH = 6

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint56 < DataType
        TYPE = 0x26
        INVALID_VALUE = 0xffffffffffffff
        LENGTH = 7

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Uint64 < DataType
        TYPE = 0x27
        INVALID_VALUE = 0xffffffffffffffff
        LENGTH = 8

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      #
      # Signed integer
      #

      class Int8 < DataType
        TYPE = 0x28
        INVALID_VALUE = 0x80

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, 1)
          value = bytes.shift
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int16 < DataType
        TYPE = 0x29
        INVALID_VALUE = 0x8000
        LENGTH = 2

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int24 < DataType
        TYPE = 0x2a
        INVALID_VALUE = 0x800000
        LENGTH = 3

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int32 < DataType
        TYPE = 0x2b
        INVALID_VALUE = 0x80000000
        LENGTH = 4

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int40 < DataType
        TYPE = 0x2c
        INVALID_VALUE = 0x8000000000
        LENGTH = 5

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int48 < DataType
        TYPE = 0x2d
        INVALID_VALUE = 0x800000000000
        LENGTH = 6

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int56 < DataType
        TYPE = 0x2e
        INVALID_VALUE = 0x80000000000000
        LENGTH = 7

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

      class Int64 < DataType
        TYPE = 0x2f
        INVALID_VALUE = 0x8000000000000000
        LENGTH = 8

        attr_reader :value

        def initialize(value)
          @value = value
        end

        def self.decode(bytes)
          ensure_has_bytes(bytes, LENGTH)
          value = 0
          LENGTH.times do
            value = value << 8 | bytes.shift
          end
          new(value)
        end

        def invalid?
          value == INVALID_VALUE
        end
      end

    end
  end
end
