require './lib/api_frame'

class Xbee
  attr_accessor :length
  attr_accessor :checksum
  attr_accessor :data

  attr_reader :serial_port

  def initialize(serial_port)
    @serial_port = serial_port
  end

  def read_api_frame
    buf = []
    char = nil
    while char != 0x7e
      char = getbyte
    end

    @length = getbyte << 8
    @length += getbyte

    @length.times do
      buf << getbyte
    end

    @checksum = getbyte

    @data = buf.pack(pack_format)

    self
  end

  def checksum_valid?
    @checksum == compute_checksum(@data)
  end

  def send_api_frame(bytes)
    unless bytes.kind_of?Array or bytes.kind_of?String
      raise ArgumentError.new('Only strings or arrays of bytes can be transmitted.')
    end

    if bytes.kind_of?Array
      bytes = pack_array(bytes)
    end

    @length = bytes.length
    @checksum = compute_checksum(bytes)

    escaped_string = "\x7e" + escape([@length, bytes, @checksum].pack("na*C"))
    serial_port.write(escaped_string)
    escaped_string
  end

  def compute_checksum(bytes)
    byte_sum = (bytes.each_byte.inject(:+)) & 0x00ff
    0xff - byte_sum
  end

  def pack_array(bytes)
    ret = "".force_encoding("BINARY")
    bytes.each do |byte|
      if byte.is_a?String
        ret << byte
      else
        ret << [byte].pack('C')
      end
    end
    ret
  end

  private

  def pack_format
    'C*'
  end

  def getbyte
    byte = serial_port.read(1)[0].ord
    if byte == 0x7d
      byte = serial_port.read(1)[0].ord
      byte = byte ^ 0x20
    end
    byte
  end

  def escape(data)
    data.gsub(/[\x11\x13\x7d\x7e]/) { |x| [ 0x7d, x.ord ^ 0x20 ].pack("CC") }
  end
end
