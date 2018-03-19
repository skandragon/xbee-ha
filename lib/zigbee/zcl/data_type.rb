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

        def valid?
          true
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
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

        def valid?
          value != INVALID_VALUE
        end
      end

      #
      # Signed integer
      #

      module SignedInt
        def self.included(base)
          base.send :include, InstanceMethods
          base.extend ClassMethods
        end

        module InstanceMethods
          attr_reader :value

          def initialize(value)
            @value = value
          end

          def valid?
            value != invalid_value
          end

          private

          def invalid_value
            1 << (self.class.length * 8 - 1)
          end

        end

        module ClassMethods
          def configure(type, length)
            self.const_set(:TYPE, type)
            self.const_set(:LENGTH, length)
            self.const_set(:INVALID_VALUE, 1 << (length * 8 - 1))
          end

          def length
            self.const_get(:LENGTH)
          end

          def invalid_value
            self.const_get(:INVALID_VALUE)
          end

          def decode(bytes)
            ensure_has_bytes(bytes, length)
            value = 0
            length.times do
              value = value << 8 | bytes.shift
            end
            value -= 1 << (length * 8) if value > invalid_value
            new(value)
          end
        end
      end

      class Int8 < DataType
        include SignedInt
        configure 0x28, 1
      end

      class Int16 < DataType
        include SignedInt
        configure 0x29, 2
      end

      class Int24 < DataType
        include SignedInt
        configure 0x2a, 3
      end

      class Int32 < DataType
        include SignedInt
        configure 0x2b, 4
      end

      class Int40 < DataType
        include SignedInt
        configure 0x2c, 5
      end

      class Int48 < DataType
        include SignedInt
        configure 0x2d, 6
      end

      class Int56 < DataType
        include SignedInt
        configure 0x2e, 7
      end

      class Int64 < DataType
        include SignedInt
        configure 0x2f, 8
      end

    end
  end
end
