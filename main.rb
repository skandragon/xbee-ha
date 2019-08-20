require 'serialport'
require 'json'
require 'mongo'
require 'time'

require 'pp'

require './xbee'
require './lib/api_frame'

require './lib/zigbee/zcl'
require './lib/zigbee/zcl/profiles/home_automation/ias'
require './lib/zigbee/zdo/profile_zdo'

#PORTNAME = '/dev/tty.usbserial-DA01MFIZ'
PORTNAME = '/dev/tty.usbserial-00000000'

Mongo::Logger.logger.level = Logger::FATAL
@db = Mongo::Client.new('mongodb://localhost/zigbee')
@log = @db[:log]
@zonestatus = @db[:zonestatus]
@attributes = @db[:attributes]
@logcounter = 0

@sent_seq = []

@sp = SerialPort.new(PORTNAME, 115200, 8, 1, SerialPort::NONE)
@xbee = Xbee.new(@sp)

def endpoint_for(addr)
  if [
      '00155f00b44cb7b6',
      '00155f00b44cdda0'
  ].include?(addr)
    0x05
  else
    0x01
  end
end

def force_extended_timeout(addr)
  [
      '00155f00b44cb7b6',
      '00155f00b44cdda0'
  ].include?(addr)
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
                  broadcast_radius = 0, options = 0, &block)
  data = data.pack('C*') if data.is_a?Array

  if force_extended_timeout('%0x16x' % node64)
    options |= 0x40
  end

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
  @sent_seq[counter] = { frame: header + data, block: block }
  puts "Sending seq #{counter}"
  hexdump header + data

  @logcounter += 1
  json = {
      ts: Time.now,
      direction: 'tx',
      logseq: @logcounter,
      frame: {
          counter: counter,
          node64: '%016x' % node64,
          node16: '%04x' % node16,
          cluster_id: cluster_id,
          profile_id: profile_id,
          src_endpoint: src_endpoint,
          dst_endpoint: dst_endpoint,
          app_data: data.unpack('H*').first
      }
  }
  @log.insert_one(json)
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
    params = @sent_seq[seq]
    @sent_seq[seq] = nil
    if params[:block]
        params[:block].call(:sent)
    end
  else
    puts ">>> Got ack for write #{seq} but not sure what it was for..."
  end
end

def nak(seq)
  if @sent_seq[seq]
    puts ">>> Got failed write for #{seq}"
    params = @sent_seq[seq]
    @sent_seq[seq] = nil
    if params[:block]
      params[:block].call(:send_failure)
    end
  else
    puts ">>> Got ack for write #{seq} but not sure what it was for..."
  end
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
      nak(frame.frame.seq)
    end

    @logcounter += 1
    json = {
        ts: Time.now,
        direction: 'txstatus',
        logseq: @logcounter,
        frame: {
            counter: frame.frame.seq,
            status: frame.frame.delivery_status
        }
    }
    @log.insert_one(json)
  elsif !frame.frame.is_a?(Xbee::ZigbeeExplicitRxIndicatorFrame)
    puts
    puts ">>> #{frame.frame.node64_string} #{frame.frame.node16_string}"
    pp frame
    hexdump frame.app_data
  end

  frame.frame
end

def log_rx(frame)
  @logcounter += 1
  json = {
      ts: Time.now,
      direction: 'rx',
      logseq: @logcounter,
      frame: {
          node64: frame.node64_string,
          node16: frame.node16_string,
          cluster_id: frame.cluster_id,
          profile_id: frame.profile_id,
          src_endpoint: frame.source_endpoint,
          dst_endpoint: frame.destination_endpoint,
          app_data: frame.app_data.unpack('H*').first
      }
  }
  @log.insert_one(json)
end

def log_zone_status(node64, endpoint, delay, status, alarm_strings)
  alarm_strings = Array(alarm_strings)
  @logcounter += 1
  json = {
      ts: Time.now,
      logseq: @logcounter,
      status: {
          node64: node64,
          endpoint: endpoint,
          status: status,
          delay: delay,
          strings: alarm_strings
      }
  }
  @zonestatus.insert_one(json)
end

def log_attribute(node64, endpoint, cluster, attribute, datatype, value)
  @logcounter += 1
  key = {
      node64: node64,
      endpoint: endpoint,
      cluster: cluster,
      attribute: attribute
  }

  json = {
      ts: Time.now,
      node64: node64,
      endpoint: endpoint,
      cluster: cluster,
      attribute: attribute,
      datatype: datatype,
      value: value
  }
  @attributes.update_one(key, json, { upsert: true })
  puts ("Attr update: cl %04x, id %04x, value " % [ cluster, attribute ]) + value.to_s
end

def receive
  apiframe = @xbee.read_api_frame
  frame = Xbee::APIFrame.new
  frame.decode(apiframe.data)
  frame.frame
end

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

@attrs = [ 0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0007, 0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x4000 ]

def read_attribute(old_frame, cluster, src_endpoint, dst_endpoint, attribute)
  puts ">>> ReadAttributee #{old_frame.node64_string}/#{old_frame.node16_string} cluster 0x%04x attribute 0x%04x" % [ cluster, attribute ]
  counter = next_counter
  command = Zigbee::ZCL::ReadAttributes.new([attribute])
  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x00)
  bytes = header.encode + command.encode
  send_explicit(counter, old_frame.node64, old_frame.node16, cluster, 0x0104, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def write_attribute(old_frame, cluster, src_endpoint, dst_endpoint, attribute, data_type, value)
  puts ">>> WriteAttribute #{old_frame.node64_string}/#{old_frame.node16_string} cluster 0x%04x attribute 0x%04x" % [ cluster, attribute ]
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
  puts ">>> EnrollResponse #{old_frame.node64_string}/#{old_frame.node16_string}"
  counter = next_counter
  request = [ status, zoneid ]

  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_LOCAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x00)
  bytes = [header.encode + request].flatten
  send_explicit(counter, old_frame.node64, old_frame.node16, 0x0500, 0x0104, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def initiate_normal_mode(old_frame, src_endpoint, dst_endpoint)
  puts ">>> EnrollResponse #{old_frame.node64_string}/#{old_frame.node16_string}"
  counter = next_counter

  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_LOCAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x01)
  bytes = header.encode
  send_explicit(counter, old_frame.node64, old_frame.node16, 0x0500, 0x0104, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def default_response(old_frame, seq, type, cluster, profile, src_endpoint, dst_endpoint, command, status)
  puts ">>> DefaultResponse #{old_frame.node64_string}/#{old_frame.node16_string} command 0x%02x status 0x%02" % [ command, status ]
  counter = next_counter
  request = [ command, status ]

  frame_control = Zigbee::ZCL::FrameControlField.new(type, 0x01, 1, 0)
  header = Zigbee::ZCL::Header.new(frame_control, seq, 0x0b)
  bytes = [header.encode + request].flatten
  send_explicit(counter, old_frame.node64, old_frame.node16, cluster, profile, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def configure_reporting(old_frame, cluster, profile, src_endpoint, dst_endpoint, attribute, data_type, minimum, maximum, reportable_change)
  puts ">>> ConfigureReporting #{old_frame.node64_string}/#{old_frame.node16_string}"
  counter = next_counter
  request = Zigbee::ZCL::ConfigureClusterReporting.new([
      Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x00, attribute, data_type, minimum, maximum, reportable_change, nil)
  ])

  frame_control = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL, 0x00, 0, 0)
  header = Zigbee::ZCL::Header.new(frame_control, counter, 0x06)
  bytes = [header.encode + request.encode].flatten
  send_explicit(counter, old_frame.node64, old_frame.node16, cluster, profile, bytes.pack('C*'), src_endpoint, dst_endpoint)
  counter
end

def active_endpoints_request(old_frame)
  puts ">>> ActiveEndpointsRequest #{old_frame.node64_string}/#{old_frame.node16_string}"
  counter = next_counter
  request = Zigbee::ZDO::ActiveEndpointsRequest.new(old_frame.node16)
  bytes = [counter] + request.encode
  send_explicit(counter, old_frame.node64, old_frame.node16, 0x0005, 0, bytes.pack('C*'), 0, 0)
  counter
end

def simple_descriptor_request(old_frame, endpoint)
  puts ">>> SimpleDescriptorRequest #{old_frame.node64_string}/#{old_frame.node16_string}"
  counter = next_counter
  request = Zigbee::ZDO::SimpleDescriptorRequest.new(old_frame.node16, endpoint)
  bytes = [counter] + request.encode
  send_explicit(counter, old_frame.node64, old_frame.node16, 0x0004, 0, bytes.pack('C*'), 0, 0)
  counter
end

def query_node_descriptor(node64, node16, &block)
  puts ">>> GetNodeDescriptor"
  counter = next_counter
  request = Zigbee::ZDO::NodeDescriptorRequest.new(node16)
  bytes = [counter] + request.encode
  send_explicit(counter, node64, node16, 0x0002, 0, bytes) { |status, response|
    block.call(status, response)
  }
  counter
end

def ota_no_image(frame, seq)
  puts ">>> OTA no image: #{frame.node64_string}/#{frame.node16_string}"
  counter = next_counter
  request = [ 0x98 ]

  frame_control = Zigbee::ZCL::FrameControlField.new(1, 0x01, 1, 0)
  header = Zigbee::ZCL::Header.new(frame_control, seq, 0x02)
  bytes = [header.encode + request].flatten
  send_explicit(counter, frame.node64, frame.node16, frame.cluster_id, frame.profile_id, bytes.pack('C*'), frame.source_endpoint, frame.destination_endpoint, 0, 0x20)
  counter
end


@devices = {}

def interrogate_device(frame)
  if !@devices[frame.node64_string]
    write_attribute(frame, 0x0500, 0x01, endpoint_for(frame.node64_string), 0x0010, 0xf0, @myid64_bytes_le.unpack('Q<').first)
    zone_enroll_response(frame, 0x01, endpoint_for(frame.node64_string), 0x00, 0x01)
    configure_reporting(frame, 0x0001, 0x0104, 0x01, endpoint_for(frame.node64_string), 0x0020, 0x20, 30, 3600, 1)
    configure_reporting(frame, 0x0402, 0x0104, 0x01, endpoint_for(frame.node64_string), 0x0000, 0x29, 30, 3600, 1)
    @devices[frame.node64_string] = @attrs.dup
  else
    next_attr = @devices[frame.node64_string].shift
    if next_attr
      read_attribute(frame, 0x0000, 0x01, endpoint_for(frame.node64_string), next_attr)
    end
  end
end

def process_frame(frame)
  handled = false

  if frame.profile_id == 0x0000
    if frame.cluster_id == 0x0013
      puts "Received device announce message from #{frame.node64_string}/#{frame.node16_string}"
      seq, addr16, addr64, capability = frame.app_data.unpack('CS<Q<C')
      cap_strings = []
      cap_strings << 'alternate-pan-controller' if (capability & 0x01) > 0
      cap_strings << 'full-function-device' if (capability & 0x02) > 0
      cap_strings << 'mains-powered' if (capability & 0x04) > 0
      cap_strings << 'receiver-on-when-idle' if (capability & 0x08) > 0
      cap_strings << 'high-security-mode' if (capability & 0x40) > 0
      cap_strings << 'allocate-address' if (capability & 0x80) > 0
      puts " Capabilities: #{cap_strings.join(', ')}"

      query_node_descriptor(frame.node64, frame.node16) { |status, data|
        case status
        when :response
          puts "Got node descriptor response"
          pp data
        else
          puts "Got status #{status} when querying node descriptor"
        end
      }

      if ['000d6f000b1b6dc2', '8418260000e8eef8', '000d6f000fe7c93b'].include?(frame.node64_string)
        active_endpoints_request(frame)
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
          interrogate_device(frame)
          handled = true
        end

        if match_request.input_clusters == [ 0x0019 ]
          puts "Received OTA server request, claiming it's us on our endpoint 0x02"
          reply = Zigbee::ZDO::MatchDescriptorResponse.new(0x00, 0x0000, [ 0x02 ])
          reply_bytes = [ seq ] + reply.encode
          send_explicit(next_counter, frame.node64, frame.node16, 0x8006, 0x0000, reply_bytes.pack('C*'))
        end
      end
    end

    if frame.cluster_id == 0x08005
      bytes = frame.app_data.unpack('C*')
      seq = bytes.shift
      response = Zigbee::ZDO::ActiveEndpointsResponse.decode(bytes)
      puts "GOT ACTIVE ENDPOINTS REPSONSE: #{response.endpoints}"
      handled = true
    end

    if frame.cluster_id == 0x08004
      bytes = frame.app_data.unpack('C*')
      seq = bytes.shift
      response = Zigbee::ZDO::SimpleDescriptorResponse.decode(bytes)
      puts "Got SimpleDescritorResponse:"
      pp response
      handled = true
    end

    if frame.cluster_id == 0x8038
      bytes = frame.app_data.unpack('C*')
      seq = bytes.shift
      response = Zigbee::ZDO::ManagementNetworkUpdateNotify.decode(bytes)
      puts "Got ManagementNetworkUpdateNotify:"
      pp response
      handled = true
    end
  end

  if frame.profile_id == 0x0104
    interrogate_device(frame)
    bytes = frame.app_data.unpack('C*')
    header = Zigbee::ZCL::Header.decode(bytes)
    if header.frame_control.frame_type == Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL
      if header.command_identifier == 0x01 # read attributes response
        response = Zigbee::ZCL::ReadAttributesResponse.decode(bytes)
        response.responses.each do |attr|
          if attr.status == 0
            log_attribute(frame.node64_string, frame.source_endpoint, frame.cluster_id, attr.id, attr.data_type, attr.value)
          end
        end
        handled = true
      end
      if header.command_identifier == 0x0a # report attributes
        response = Zigbee::ZCL::ReportAttributes.decode(bytes)
        response.responses.each do |attr|
          log_attribute(frame.node64_string, frame.source_endpoint, frame.cluster_id, attr.id, attr.data_type, attr.value)
        end
        handled = true
      end
      if header.command_identifier == 0x0b # default response
        response = Zigbee::ZCL::DefaultResponse.decode(bytes)
        pp header
        pp response
        handled = true
      end
    else # local command
      if frame.cluster_id == 0x0500 && header.command_identifier == 0x00
        unless header.frame_control.disable_default_response
          default_response(frame, header.transaction_sequence_number, Zigbee::ZCL::FrameControlField::FRAME_TYPE_LOCAL,
                           0x0500, 0x0104, frame.destination_endpoint, frame.source_endpoint, header.command_identifier, 0)
        end
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

        log_zone_status(frame.node64_string, frame.source_endpoint, update.delay, update.status, zone_status_list)

        #zone_enroll_response(frame, 0x01, frame.source_endpoint, 0x00, 0x01)
      end
      if frame.cluster_id == 0x0019 && header.command_identifier == 0x01
        puts "Got OTA firmware update reqest, lying..."
        ota_no_image(frame, header.transaction_sequence_number)
        handled = true
      end
    end

    unless handled
      puts "UNHANDLED message"
      puts frame
      pp header
      hexdump bytes.pack('C*')
      handled = true
    end
  end

  unless handled
    puts
    puts "UNHANDLED MESSAGE: "
    puts frame
    puts " App data:"
    hexdump frame.app_data
  end
end

loop do
  frame = receive_and_dump
  next unless frame.is_a?(Xbee::ZigbeeExplicitRxIndicatorFrame)
  log_rx(frame)
  begin
    process_frame(frame)
  rescue Exception => e
    puts "EXCEPTION: "
    puts e.message
    puts e.backtrace
    pp frame
    hexdump frame.frame.app_data
    puts "END EXCEPTION"
  end
end
