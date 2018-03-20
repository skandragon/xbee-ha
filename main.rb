require 'serialport'
require 'json'
require 'pp'

require './xbee'
require './lib/api_frame'

require_relative 'lib/zigbee/zcl'

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

def send_explicit(counter, node64, node16, cluster_id, profile_id, data,
                  src_endpoint = 0, dst_endpoint = 0,
                  broadcast_radius = 0, options = 0)
  header = [
      0x11,
      counter,
      node64,
      node16,
      src_endpoint,
      dst_endpoint,
      cluster_id,
      profile_id,
      broadcast_radius,
      options
  ].pack('CCQ>S>CCS>S>CC')
  @xbee.send_api_frame(header + data)
end

def receive_and_dump
  apiframe = @xbee.read_api_frame
  hexdump apiframe.data, "<< "

  frame = Xbee::APIFrame.new
  frame.decode(apiframe.data)
  pp frame.frame
  if frame.respond_to?:app_data
    hexdump frame.app_data
  end
  frame.frame
end

@sp = SerialPort.new(portname, 115200, 8, 1, SerialPort::NONE)
@xbee = Xbee.new(@sp)


@counter = 1

loop do
  frame = receive_and_dump

  next unless frame.is_a?(Xbee::ZigbeeExplicitRxIndicatorFrame)
  if frame.cluster_id == 0x0013
    puts "Received device announce message."
    puts "Sending Active Endpoint Request"

    data = [
        0xaa,
        frame.node16,
    ].pack('CS<')

    send_explicit(@counter, frame.node64, frame.node16, 0x0005, 0x0000, data)
  end

  if frame.cluster_id == 0x8005
    puts "Received Active Endpoint Response"
    puts "  Endpoint count: "  + frame.app_data[4].ord.to_s # TODO: decode better
    puts "  Active Endpoint: "  + frame.app_data[5].ord.to_s
    puts "Sending Simple Descriptor Request"

    data = [
        0xaa,
        frame.node16,
        frame.app_data[5].ord
    ].pack('CS<C')
    send_explicit(@counter, frame.node64, frame.node16, 0x0004, 0x0000, data)
  end

  if frame.cluster_id == 0x8004
    puts "Received Simple Descriptor Response"
    app_data = frame.app_data
    transaction_id, _, _, _, _, endpoint, profile_id, device_id, device_version, input_cluster_count, app_data = frame.app_data.unpack('CCCCCCS>S>CCa*')

    input_cluster_ids = []
    input_cluster_count.times do
      cluster_id, app_data = app_data.unpack("S<a*")
      input_cluster_ids << cluster_id
    end

    output_cluster_count, app_data = app_data.unpack("Ca*")
    output_cluster_ids = []
    output_cluster_count.times do
      cluster_id, app_data = app_data.unpack("S<a*")
      output_cluster_ids << cluster_id
    end

    puts " Transaction ID: #{transaction_id}"
    puts " Endpoint reported: #{endpoint}"
    puts " Profile ID: " + ('%04x' % profile_id)
    puts " Device ID: " +  ('%04x' % device_id)
    puts " Device version: #{device_version}"
    puts " Input cluster count: #{input_cluster_count}"
    puts "   " + input_cluster_ids.map { |x| '%04x' % x }.join(", ")
    puts " Output cluster count: #{output_cluster_count}"
    puts "   " + output_cluster_ids.map { |x| '%04x' % x }.join(", ")

    data = [
        0x00, @counter, 0x06,
        0x00, 0x00, 0x10, 0x00, 0x40, 0x00
    ].pack('CCCCS>CS>S>S>')
    send_explicit(@counter, frame.node64, frame.node16, 0x0402, 0x0104, data, 0, endpoint)
  end

end
