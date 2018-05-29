require_relative '../../utils'

module Zigbee
  module ZCL
    class DataType
      include ArrayUtils

      attr_reader :type

      def self.class_for(value)
        if value.is_a?(Symbol) || value.is_a?(String)
          MAP_SYMBOL[value.to_sym]
        else
          MAP[value]
        end
      end

      def self.decode(bytes)
        type = decode_uint8(bytes)

        subclasses = ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
        subclass = subclasses.select { |klass| klass.const_get(:TYPE) == type }.first
        if subclass.nil?
          throw ArgumentError.new("Cannot find data type for type 0x#{type.to_s(16)}")
        end
        @type = type
        subclass.decode_data(bytes)
      end

      def decode_data(bytes)
        raise StandardError.new("Invalid data type implementation, needs to define #decode_data")
      end

      def encode
        [ self.class.const_get(:TYPE) ] + encode_data
      end

      def encode_data
        raise StandardError.new("Invalid data type implementation, needs to define #encode_data")
      end

      class NoData < DataType
        TYPE = 0x00

        def initialize(value)
        end

        def self.decode_data(_bytes)
          new(nil)
        end

        def encode_data
          []
        end

        def valid?
          true
        end
      end

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

          def encode_data
            length = self.class.const_get(:LENGTH)
            val = @value
            length.times.map {
              ret = val & 0xff
              val >>= 8
              ret
            }
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

          def decode_data(bytes)
            ensure_has_bytes(bytes, length)
            value = 0
            length.times do |time|
              value |= decode_uint8(bytes) << (8 * time)
            end
            new(value)
          end
        end
      end

      #
      # MAPs
      #

      class Map8 < DataType
        include UnsignedInt
        configure 0x18, 1
      end

      class Map16 < DataType
        include UnsignedInt
        configure 0x19, 2
      end

      class Map24 < DataType
        include UnsignedInt
        configure 0x1a, 3
      end

      class Map32 < DataType
        include UnsignedInt
        configure 0x1b, 4
      end

      class Map40 < DataType
        include UnsignedInt
        configure 0x1c, 5
      end

      class Map48 < DataType
        include UnsignedInt
        configure 0x1d, 6
      end

      class Map56 < DataType
        include UnsignedInt
        configure 0x1e, 7
      end

      class Map64 < DataType
        include UnsignedInt
        configure 0x1f, 8
      end

      #
      # Unsigned Integers
      #

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

          def encode_data
            length = self.class.const_get(:LENGTH)
            val = @value
            length.times.map {
              ret = val & 0xff
              val >>= 8
              ret
            }
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

          def decode_data(bytes)
            ensure_has_bytes(bytes, length)
            value = 0
            length.times do |time|
              value |= decode_uint8(bytes) << (8 * time)
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

      class Enum8 < DataType
        attr_reader :value

        TYPE = 0x30

        def initialize(value)
          @value = value
        end

        def self.decode_data(bytes)
          @value = decode_uint8(bytes)
        end

        def encode_data
          [ @value & 0xff ]
        end

        def valid?
          @value != 0xff
        end

        def length
          1
        end
      end

      class CharacterString < DataType
        attr_reader :value

        TYPE = 0x42

        def initialize(value)
          @value = value
        end

        def self.decode_data(bytes)
          length = decode_uint8(bytes)
          if length == 0xff
            new(nil)
          else
            val = length.times.map { decode_uint8(bytes) }
            new(val.pack('C*'))
          end
        end

        def encode_data
          if value
            ([length] + value.each_byte.map(&:ord)).flatten
          else
            [ 0xff ]
          end
        end

        def valid?
          value
        end

        def length
          value.nil? ? 1 : value.length
        end
      end

      class EUI64 < DataType
        attr_reader :value

        TYPE = 0xf0

        def initialize(value)
          @value = value
        end

        def self.decode_data(bytes)
          ensure_has_bytes(bytes, 8)
          value = 0
          8.times do |time|
            value |= decode_uint8(bytes) << (8 * time)
          end
          new(value)
        end

        def encode_data
          val = value
          8.times.map {
            ret = val & 0xff
            val >>= 8
            ret
          }
        end

        def valid?
          value != 0xffffffffffffffff
        end

        def length
          8
        end
      end

      MAP = {
          0x00 => NoData,
          0x18 => Map8,
          0x19 => Map16,
          0x1a => Map24,
          0x1b => Map32,
          0x1c => Map40,
          0x1d => Map48,
          0x1e => Map56,
          0x1f => Map64,
          0x20 => Uint8,
          0x21 => Uint16,
          0x22 => Uint24,
          0x23 => Uint32,
          0x24 => Uint40,
          0x25 => Uint48,
          0x26 => Uint56,
          0x27 => Uint64,
          0x28 => Int8,
          0x29 => Int16,
          0x2a => Int24,
          0x2b => Int32,
          0x2c => Int40,
          0x2d => Int48,
          0x2e => Int56,
          0x2f => Int64,
          0x30 => Enum8,
          0x42 => CharacterString,
          0xf0 => EUI64
      }

      MAP_SYMBOL = {
          nodata: NoData,
          map8: Map8,
          map16: Map16,
          map24: Map24,
          map32: Map32,
          map40: Map40,
          map48: Map48,
          map56: Map56,
          map64: Map64,
          uint8: Uint8,
          uint16: Uint16,
          uint24: Uint24,
          uint32: Uint32,
          uint40: Uint40,
          uint48: Uint48,
          uint56: Uint56,
          uint64: Uint64,
          int8: Int8,
          int16: Int16,
          int24: Int24,
          int32: Int32,
          int40: Int40,
          int48: Int48,
          int56: Int56,
          int64: Int64,
          enum8: Enum8,
          character_string: CharacterString,
          eui64: EUI64
      }

    end
  end
end
