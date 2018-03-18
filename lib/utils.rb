module ArrayUtils
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
  end

  module ClassMethods
    def ensure_array(array)
      raise ArgumentError.new("Argument is not an array") unless array.is_a?Array
    end

    def ensure_has_bytes(array, expected)
      ensure_array(array)
      raise ArgumentError.new("Expected #{expected} bytes, but only #{array.length} remain") if array.length < expected
    end
  end
end
