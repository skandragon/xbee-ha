require 'serialport'
require 'json'
require 'pp'

require './xbee'
require './lib/api_frame'

require_relative 'lib/zigbee/zcl'
require_relative 'lib/zigbee/zcl/profiles/home_automation/ias'

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

@counter = 0
def next_counter
  @counter = (@counter + 1) & 0xff
  @counter = 1 if @counter == 0
  @counter
end

def read_zcl_header(data)
  flags, seq, cmd, remaining = data.unpack('CCCa*')
  [ flags, seq, cmd, remaining ]
end

@attrs = [ ] # 0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0007 ]

def read_attribute(old_frame, cluster, src_endpoint, dst_endpoint, attribute)
  puts ">>> ReadAttribute #{old_frame.node64_string}/#{old_frame.node16_string} cluster 0x%04x attribute 0x%04x" % [ cluster, attribute]
  counter = next_counter
  command = Zigbee::ZCL::ReadAttributes.new([attribute])
  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x00)
  bytes = header.encode + command.encode
  send_explicit(counter, old_frame.node64, old_frame.node16, cluster, 0x0104, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def write_attribute(old_frame, cluster, src_endpoint, dst_endpoint, attribute, data_type, value)
  puts ">>> WriteAttribute #{old_frame.node64_string}/#{old_frame.node16_string} cluster 0x%04x attribute 0x%04x" % [ cluster, attribute]
  counter = next_counter
  request = Zigbee::ZCL::WriteAttributes::Request.new(attribute, data_type, value)

  command = Zigbee::ZCL::WriteAttributes.new([request])
  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x02)
  bytes = header.encode + command.encode
  send_explicit(counter, old_frame.node64, old_frame.node16, cluster, 0x0104, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def zone_enroll_response(old_frame, src_endpoint, dst_endpoint, status, zoneid)
  puts ">>> EnrollResponse #{old_frame.node64_string}/#{old_frame.node16_string} cluster 0x%04x attribute 0x%04x"
  counter = next_counter
  request = [ status, zoneid ]

  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_LOCAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x00)
  bytes = [header.encode + request].flatten
  send_explicit(counter, old_frame.node64, old_frame.node16, 0x0500, 0x0104, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

loop do
  frame = receive_and_dump
  handled = false

  next unless frame.is_a?(Xbee::ZigbeeExplicitRxIndicatorFrame)
  if frame.profile_id == 0x0000
    if frame.cluster_id == 0x0013
      puts "Received device announce message from #{frame.node64_string}/#{frame.node16_string}"
      seq, addr16, addr64, capability = frame.app_data.unpack('CS<Q<C')
      if capability != 0
        print "  Capabilities: "
        print "  AlternatePanController" if (capability & 0x01) > 0
        print "  FullFunctionDevice" if (capability & 0x02) > 0
        print "  MainsPower" if (capability & 0x04) > 0
        print "  ReceiverOnWhenIdle" if (capability & 0x08) > 0
        print "  HighSecurityMode" if (capability & 0x40) > 0
        print "  AllocateAddress" if (capability & 0x80) > 0
        puts
      end

      handled = true
    end

    if frame.cluster_id == 0x0006
      puts "Received match descriptor request from #{frame.node64_string}/#{frame.node16_string}"
      bytes = frame.app_data.unpack('C*')
      seq = bytes.shift
      match_request = Zigbee::ZDO::MatchDescriptorRequest.decode(bytes)

      puts "  Sequence: 0x%02x" % seq
      puts "  Profile 0x%04x" % match_request.profile_id
      puts "  Address: 0x%04x" % match_request.address
      cluster_string = match_request.input_clusters.map { |x| "%04x" % x }
      puts "  Input clusters: " + cluster_string.join(", ")

      cluster_string = match_request.output_clusters.map { |x| "%04x" % x }
      puts "  Output clusters: " + cluster_string.join(", ")

      if match_request.profile_id == 0x0104
        if match_request.output_clusters.include?(0x0500)
          reply = Zigbee::ZDO::MatchDescriptorResponse.new(0x00, 0x0000, [ 0x01 ])
          reply_bytes = [ seq ] + reply.encode
          send_explicit(next_counter, frame.node64, frame.node16, 0x8006, 0x0000, reply_bytes.pack('C*'))

          next_attr = @attrs.shift
          if next_attr
            read_attribute(frame, 0x0000, 0x01, 0x01, next_attr)
          else
            write_attribute(frame, 0x0500, 0x01, 0x05, 0x0010, 0xf0, @myid64_bytes_le.unpack('Q<').first)
            zone_enroll_response(frame, 0x01, 0x05, 0x00, 0x01)
          end
          handled = true
        end
      end
    end
  end

  if frame.profile_id == 0x0104
    bytes = frame.app_data.unpack('C*')
    header = Zigbee::ZCL::Header.decode(bytes)
    if header.frame_control.frame_type == Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL
      if header.command_identifier == 0x01 # read attributes response
        if frame.cluster_id == 0x0000
          response = Zigbee::ZCL::ReadAttributesResponse.decode(bytes)
          pp response

          next_attr = @attrs.shift
          if next_attr
            read_attribute(frame, 0x0000, 0x01, 0x01, next_attr)
          else
            write_attribute(frame, 0x0500, 0x01, 0x05, 0x0010, 0xf0, @myid64_bytes_le.unpack('Q<').first)
            zone_enroll_response(frame, 0x01, 0x05, 0x00, 0x01)
          end
          handled = true
        end
      end
    else # local command
      if frame.cluster_id == 0x0500 && header.command_identifier == 0x00
        update = Zigbee::ZCL::Profiles::HomeAutomation::IAS::ZoneStatusChange.decode(bytes)
        zone_status_list = []
        zone_status_list << 'alarm1' if (update.status & 0x0001) != 0
        zone_status_list << 'alarm2' if (update.status & 0x0002) != 0
        zone_status_list << 'tampered' if (update.status & 0x0004) != 0
        zone_status_list << 'battery-low' if (update.status & 0x0008) != 0
        zone_status_list << 'supervision-reports' if (update.status & 0x0010) != 0
        zone_status_list << 'restore-reports' if (update.status & 0x0020) != 0
        zone_status_list << 'trouble' if (update.status & 0x0040) != 0
        zone_status_list << 'ac-mains-fault' if (update.status & 0x0080) != 0
        zone_status_list << 'test-mode' if (update.status & 0x0100) != 0
        zone_status_list << 'battery-defect' if (update.status & 0x0200) != 0
        puts "ZONE STATUS CHANGE: #{frame.node64_string}/#{frame.node16_string} #{zone_status_list.join(', ')} zone=#{update.zone_id} delay=#{update.delay}"
        handled = true
      end
    end

    unless handled
      puts "UNHANDLED message"
      puts frame
      puts header
      hexdump bytes.pack('C*')
      handled = true
    end
  end

  unless handled
    puts
    puts "UNHANDLED MESSAGE: "
    pp frame
    puts " App data:"
    hexdump frame.app_data
  end
end
