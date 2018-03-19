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

      #
      # Unsigned Integers
      #

      module UnsignedInt
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
            self.class.const_get(:INVALID_VALUE)
          end

        end

        module ClassMethods
          def configure(type, length)
            self.const_set(:TYPE, type)
            self.const_set(:LENGTH, length)
            invalid_value = 0
            (length * 8).times do
              invalid_value = (invalid_value << 1) | 0x01
            end
            self.const_set(:INVALID_VALUE, invalid_value)
          end

          def length
            self.const_get(:LENGTH)
          end

          def decode(bytes)
            ensure_has_bytes(bytes, length)
            value = 0
            length.times do
              value = value << 8 | bytes.shift
            end
            new(value)
          end
        end
      end

      class Uint8 < DataType
        include UnsignedInt
        configure 0x20, 1
      end

      class Uint16 < DataType
        include UnsignedInt
        configure 0x21, 2
      end

      class Uint24 < DataType
        include UnsignedInt
        configure 0x22, 3
      end

      class Uint32 < DataType
        include UnsignedInt
        configure 0x23, 4
      end

      class Uint40 < DataType
        include UnsignedInt
        configure 0x24, 5
      end

      class Uint48 < DataType
        include UnsignedInt
        configure 0x25, 6
      end

      class Uint56 < DataType
        include UnsignedInt
        configure 0x26, 7
      end

      class Uint64 < DataType
        include UnsignedInt
        configure 0x27, 8
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
