require 'serialport'
require 'json'
require 'pp'

require './xbee'
require './lib/api_frame'

def portname
  '/dev/tty.usbserial-AD01SUG4'
end

def hexdump(data, msg = nil)
  i = 0
  bytes = data[i..(i + 15)]
  while bytes
    puts "#{msg}%04x %s" % [i, bytes.unpack('H2' * 16).join(' ')]
    i += 16
    bytes = data[i..(i + 15)]
  end
end

@sp = SerialPort.new(portname, 115200, 8, 1, SerialPort::NONE)
@xbee = Xbee.new(@sp)

apiframe = @xbee.read_api_frame
hexdump apiframe.data, "<< "

frame = Xbee::ZigbeeExplicitRxIndicatorFrame.new(apiframe.data)
pp frame
hexdump frame.app_data
