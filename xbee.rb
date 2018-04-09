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

    length_bytes = getbytes(2)
    @length = (length_bytes[0] << 8) | length_bytes[1]

    getbytes(@length).each { |byte| buf << byte }

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

  def getbytes(length)
    ret = []
    escape_needed = false

    while length > 0
      bytes = serial_port.read(length)
      bytes.length.times do |index|
        byte = bytes[index].ord
        if byte == 0x7d
          escape_needed = true
        else
          if escape_needed
            ret << (byte ^ 0x20)
            escape_needed = false
          else
            ret << byte
          end
        end
      end
      length -= ret.length
    end
    ret
  end

  def escape(data)
    data.gsub(/[\x11\x13\x7d\x7e]/) { |x| [ 0x7d, x.ord ^ 0x20 ].pack("CC") }
  end
end
