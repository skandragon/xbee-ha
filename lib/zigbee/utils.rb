module Zigbee
  module ArrayUtils
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def encode_uint8(*values)
        self.class.encode_uint8(*values)
      end

      def decode_uint8(bytes, count = nil)
        self.class.decode_uint8(bytes, count)
      end

      def encode_uint16(*values)
        self.class.encode_uint16(*values)
      end

      def decode_uint16(bytes, count = nil)
        self.class.decode_uint16(bytes, count)
      end

      def encode_uint32(*values)
        self.class.encode_uint32(*values)
      end

      def decode_uint32(bytes, count = nil)
        self.class.decode_uint32(bytes, count)
      end

      def encode_uint64(*values)
        self.class.encode_uint64(*values)
      end

      def decode_uint64(bytes, count = nil)
        self.class.decode_uint64(bytes, count)
      end

      def ensure_has_bytes(array, expected)
        self.class.ensure_has_bytes(array, expected)
      end
    end

    module ClassMethods
      def ensure_array(array)
        raise ArgumentError, "Argument is not an array" unless array.is_a?Array
      end

      def ensure_has_bytes(array, expected)
        ensure_array(array)
        raise ArgumentError, "Expected #{expected} bytes, but only #{array.length} remain" if array.length < expected
      end

      def encode_uint8(*values)
        values.map { |value| value & 0xff }
      end

      def decode_uint8(bytes, count = nil)
        if count.nil?
          bytes.shift
        else
          count.times.map { bytes.shift }
        end
      end

      def encode_uint16(*values)
        values.map { |value| [ value & 0xff, (value >> 8) & 0xff ] }.flatten
      end

      def decode_uint16(bytes, count = nil)
        if count.nil?
          bytes.shift | bytes.shift << 8
        else
          count.times.map { bytes.shift | bytes.shift << 8 }
        end
      end

      def encode_uint32(*values)
        values.map { |value| [ value & 0xff, (value >> 8) & 0xff, (value >> 16) & 0xff, (value >> 24) & 0xff ] }.flatten
      end

      def decode_uint32(bytes, count = nil)
        if count.nil?
          bytes.shift | bytes.shift << 8 | bytes.shift << 16 | bytes.shift << 24
        else
          count.times.map { bytes.shift | bytes.shift << 8 | bytes.shift << 16 | bytes.shift << 24 }
        end
      end

      def encode_uint64(*values)
        values.map { |value| [
            value & 0xff,
            (value >> 8) & 0xff,
            (value >> 16) & 0xff,
            (value >> 24) & 0xff,
            (value >> 32) & 0xff,
            (value >> 40) & 0xff,
            (value >> 48) & 0xff,
            (value >> 56) & 0xff
        ] }.flatten
      end

      def decode_uint64(bytes, count = nil)
        if count.nil?
          (bytes.shift | bytes.shift << 8 | bytes.shift << 16 | bytes.shift << 24 |
              bytes.shift << 32 | bytes.shift << 40 | bytes.shift << 48 | bytes.shift << 56)
        else
          count.times.map {
            (bytes.shift | bytes.shift << 8 | bytes.shift << 16 | bytes.shift << 24 |
                bytes.shift << 32 | bytes.shift << 40 | bytes.shift << 48 | bytes.shift << 56)
          }
        end
      end
    end
  end
end
