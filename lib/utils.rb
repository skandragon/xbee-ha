module ArrayUtils
  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
    def encode_uint16(value)
      self.class.encode_uint16(value)
    end

    def extract_uint16(value)
      self.class.extract_uint16(value)
    end
  end

  module ClassMethods
    def ensure_array(array)
      raise ArgumentError.new("Argument is not an array") unless array.is_a?Array
    end

    def ensure_has_bytes(array, expected)
      ensure_array(array)
      raise ArgumentError.new("Expected #{expected} bytes, but only #{array.length} remain") if array.length < expected
    end

    def encode_uint16(value)
      [ value & 0xff, (value >> 8) & 0xff ]
    end

    def extract_uint16(bytes)
      bytes.shift | bytes.shift << 8
    end
  end
end
