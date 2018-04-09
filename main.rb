require 'serialport'
require 'json'
require 'pp'

require './xbee'
require './lib/api_frame'

require_relative 'lib/zigbee/zcl'

@sensors = {}
@sent_seq = []

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
  @sent_seq[counter] = header + data
  puts "Sending seq #{counter}"
  hexdump header + data
end

def send_at_command(counter, command)
  header = [
      0x08,
      counter,
  ].pack('CC')
  @xbee.send_api_frame(header + command)
end

def ack(seq)
  if @sent_seq[seq]
    puts ">>> Got ack for write #{seq}"
    @sent_seq[seq] = nil
  else
    puts ">>> Got ack for write #{seq} but not sure what it was for..."
  end
  @sensors.values.each { |sensor|
    if sensor[:enroll_response_seq] == seq
      sensor[:enrolled] = true
      sensor.delete(:enroll_response_seq)
      puts ">>> Got reply to enroll request"
    end
  }
end

def receive_and_dump
  apiframe = @xbee.read_api_frame

  frame = Xbee::APIFrame.new
  frame.decode(apiframe.data)
  if frame.frame.is_a?(Xbee::ZigbeeTransmitStatusFrame)
    status = frame.frame.delivery_status
    if status == 0
      ack(frame.frame.seq)
    else
      puts ">>> TRANSMIT STATUS: 0x#{frame.frame.delivery_status.to_s(16)} sequence 0x#{frame.frame.seq.to_s(16)}"
      if @sent_seq[frame.frame.seq]
        puts ">>> Failed to send this data:"
        hexdump @sent_seq[frame.frame.seq]
        @sent_seq[frame.frame.seq] = nil
      end
    end
  else
    if frame.is_a?(Xbee::ZigbeeExplicitRxIndicatorFrame)
      puts
      puts ">>> #{frame.frame.node64_string} #{frame.frame.node16_string}"
      hexdump frame.app_data
    end
  end

  frame.frame
end

def receive
  apiframe = @xbee.read_api_frame
  frame = Xbee::APIFrame.new
  frame.decode(apiframe.data)
  frame.frame
end

@sp = SerialPort.new(portname, 115200, 8, 1, SerialPort::NONE)
@xbee = Xbee.new(@sp)

sleep 1
@counter = 1

send_at_command(@counter, "SH")
frame = nil
begin
  frame = receive
end until frame.is_a?(Xbee::AtCommandResponseFrame)
@myid64 = ('%08x' % frame.value)
@counter += 1

send_at_command(@counter, "SL")
begin
  frame = receive
end until frame.is_a?(Xbee::AtCommandResponseFrame)
@myid64 += ('%08x' % frame.value)

puts "My IEEE address: #{@myid64}"
@myid64_bytes_le = [ @myid64.to_i(16) ].pack('Q<')

send_at_command(@counter, "MY")
begin
  frame = receive
end until frame.is_a?(Xbee::AtCommandResponseFrame)
@myid16 = ('%04x' % frame.value)

puts "My 16-bit address address: #{@myid16}"
@myid16_bytes_le = [ @myid16.to_i(16) ].pack('S<')

@counter = 0xaa

def find_sensor(frame)
  @sensors[frame.node64_string] ||= {}
  @sensors[frame.node64_string]
end

def send_address_and_enroll(frame)
  sensor = find_sensor(frame)
  puts "Sending Write with our address"
  @counter += 1
  data = [
      0x00, @counter, 0x02,
      0x0010, # attribute
      0xf0, # type: EUID64
      @myid64_bytes_le
  ].pack('CCCS<Ca*')
  send_explicit(@counter, frame.node64, frame.node16, 0x0500, 0x0104, data, 1, sensor[:endpoint])

  puts ">>> Sending enroll response"
  @counter += 1
  data = [
      0x01, @counter, 0x00,
      0x00, 0x00
  ].pack('CCCCC')
  hexdump data, '>> '
  sensor[:enroll_response_seq] = @counter
  send_explicit(@counter, frame.node64, frame.node16, 0x0500, 0x0104, data, 1, sensor[:endpoint])
end

def send_configure_reporting(frame)
  sensor = find_sensor(frame)
  puts "Sending configure reporting"
  @counter += 1
  data = [
      0x00, @counter, 0x06,
      0x00,
      0x0010, # what id?
      0xf0, # hmmm, what attribute type goes here?
      60,
      300,
      1
  ]
end

def read_zcl_header(data)
  flags, seq, cmd, remaining = data.unpack('CCCa*')
  [ flags, seq, cmd, remaining ]
end

loop do
  frame = receive_and_dump
  handled = false

  next unless frame.is_a?(Xbee::ZigbeeExplicitRxIndicatorFrame)
  if frame.profile_id == 0x0000 && frame.cluster_id == 0x0013
    puts "Received device announce message from #{frame.node64_string}/#{frame.node16_string}"
    seq, addr16, addr64, capability = frame.app_data.unpack('CS<Q<C')
    if capability != 0
      print " Capabilities: "
      print " AlternatePanController" if (capability & 0x01) > 0
      print " FullFunctionDevice" if (capability & 0x02) > 0
      print " MainsPower" if (capability & 0x04) > 0
      print " ReceiverOnWhenIdle" if (capability & 0x08) > 0
      print " HighSecurityMode" if (capability & 0x40) > 0
      print " AllocateAddress" if (capability & 0x80) > 0
      puts
    end

    sensor = find_sensor(frame)

    sent = false
    if !sent && sensor[:endpoint].nil?
      puts "Sending Active Endpoint Request"
      @counter += 1
      data = [
          @counter,
          frame.node16,
      ].pack('CS<')
      send_explicit(@counter, frame.node64, frame.node16, 0x0005, 0x0000, data)
      sent = true
    end

    if !sent && sensor[:descriptors].nil? && sensor[:endpoint]
      puts "Sending Simple Descriptor Request"
      @counter += 1
      data = [
          @counter,
          frame.node16,
          sensor[:endpoint]
      ].pack('CS<C')
      send_explicit(@counter, frame.node64, frame.node16, 0x0004, 0x0000, data)
      sent = true
    end

    if !sent && sensor[:enrolled].nil? && sensor[:descriptors] && sensor[:endpoint]
      send_address_and_enroll(frame)
      sent = true
    end

    handled = true
  end

  if frame.profile_id == 0x0000 && frame.cluster_id == 0x8005
    sensor = find_sensor(frame)
    puts "Received Active Endpoint Response"
    puts "  Endpoint count: "  + frame.app_data[4].ord.to_s # TODO: decode better
    puts "  Active Endpoint: "  + frame.app_data[5].ord.to_s
    sensor[:endpoint] = frame.app_data[5].ord

    if sensor[:enrolled].nil? && sensor[:endpoint]
      send_address_and_enroll(frame)
      sensor[:enrolled] = true # ignores errors
      #sent = true
    end
    handled = true
  end

  if frame.profile_id == 0x0000 && frame.cluster_id == 0x8004
    sensor = find_sensor(frame)
    puts "Received Simple Descriptor Response"
    app_data = frame.app_data
    if frame.app_data.length < 12
      puts "Error: too few bytes!"
      return
    end
    transaction_id, _, _, _, _, endpoint, profile_id, device_id, device_version, input_cluster_count, app_data = app_data.unpack('CCCCCCS<S<CCa*')

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

    sensor[:descriptors] = {
        transaction_id: transaction_id,
        endpoint: endpoint,
        profile: profile_id,
        device: device_id,
        device_version: device_version,
        input_clusters: input_cluster_ids,
        input_cluster_strings: input_cluster_ids.map { |x| "%04x" % x },
        output_clusters: output_cluster_ids,
        output_cluster_strings: output_cluster_ids.map { |x| "%04x" % x },
    }
    puts JSON::generate(sensor[:descriptors])

    handled = true
  end

  if frame.profile_id == 0x0104 && frame.cluster_id == 0x0000
    flags, zcl_seq, cmd, app_data = read_zcl_header(frame.app_data)
    attr, app_data = app_data.unpack('S<a*')
    puts ">> Read request for global attribute 0x#{attr.to_s(16)}"
    if attr == 0x0000 # ZCL version
      data = [
          0x08, zcl_seq, 0x01,
          attr, 0x00, 0x20, 0x02
      ].pack('CCCS<CCC')
      @counter += 1
      send_explicit(@counter, frame.node64, frame.node16, 0x0000, 0x0104, data, 0, 1) # TODO: use real endpoint here
      handled = true
    end
    if attr == 0x0001 # App version
      data = [
          0x08, zcl_seq, 0x01,
          attr, 0x00, 0x20, 0x01
      ].pack('CCCS<CCC')
      @counter += 1
      send_explicit(@counter, frame.node64, frame.node16, 0x0000, 0x0104, data, 0, 1) # TODO: use real endpoint here
      handled = true
    end
  end

  if frame.profile_id == 0x0104 && frame.cluster_id == 0x0500
    flags, zcl_seq, cmd, app_data = read_zcl_header(frame.app_data)
    # check zcl command
    if (flags & 0x01) == 0
      if cmd == 0x04 # write result
        status = app_data[0].ord
        puts frame
        puts " Got write status: 0x#{status.to_s(16)}"
        handled = true
      end
      if cmd == 0x0b # default response
        command = app_data[0].ord
        status = app_data[1].ord
        puts frame
        puts " Got default response: command 0x#{command.to_s(16)} status 0x#{status.to_s(16)}"
        handled = true
      end
    else # cluster specific
      if cmd == 0x00 # zone status update
        status, _, zoneid, delay = app_data[0..5].unpack('S<CCS<')
        puts " Got zone status update: status=0x#{status.to_s(16)}, zoneid=#{zoneid}, delay=#{delay}"
        handled = true
      end
    end
  end

  if frame.profile_id == 0x0000 && frame.cluster_id == 0x0000
    cmd = frame.app_data[2].ord
    if cmd == 0x00
      id = frame.app_data[3].ord | (frame.app_data[4].ord << 8)
      if id == 0x0000
        data = [
            0x81,
        ]
      end
    end
  end

  if frame.profile_id == 0x0000 && frame.cluster_id == 0x0006
    seq, addr, profile, incount, remaining = frame.app_data.unpack('CS<S<Ca*')
    initems = []
    incount.times do
      item, remaining = remaining.unpack('S<a*')
      initems << item
    end
    outcount, remaining = remaining.unpack('Ca*')
    outitems = []
    outcount.times do
      item, remaining = remaining.unpack('S<a*')
      outitems << item
    end
    json = {
        seq: seq, addr: addr, profile: profile, in_items: initems, out_items: outitems
    }
    puts frame
    puts JSON.generate(json)
    handled = true

    if addr == 0xfffd && profile == 0x0104 && outitems.include?(0x0500)
      puts "Sending Match Descriptor Response for 0x0500"
      @counter += 1
      data = [
          seq,
          0,
          0x0000,
          1,
          1
      ].pack('CCS<CC')
      send_explicit(@counter, frame.node64, frame.node16, 0x8006, 0x0000, data)
    end

    if addr == 0xfffd && profile == 0x0104 && initems.include?(0x0019)
      puts "Sending Match Descriptor Response for 0x0019"
      @counter += 1
      data = [
          seq,
          0x89,
          0x0000,
          0
      ].pack('CCS<C')
      send_explicit(@counter, frame.node64, frame.node16, 0x8006, 0x0000, data)
    end

  end

  unless handled
    puts
    puts "UNHANDLED MESSAGE: "
    pp frame
    hexdump frame.app_data
  end
end
