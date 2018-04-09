class Xbee

  @@frametypes = nil
  @@frame_identifier_to_class = {}

  def self.frame_types
    find_frame_types
    @@frametypes
  end

  def self.class_from_identifier(identifier)
    find_frame_types
    @@frame_identifier_to_class[identifier] || UnknownFrameType
  end

  private

  def self.find_frame_types
    return if @@frametypes

    classes = constants.map { |c| const_get(c) } .
          select { |c| c.is_a? Class and c.respond_to?(:identifier) and c.respond_to?(:description) }

    classes.each do |klass|
      @@frame_identifier_to_class[klass.identifier] = klass
    end
  end

  class APIFrame
    attr_accessor :raw_packet
    attr_accessor :raw_data
    attr_accessor :command
    attr_accessor :frame

    def initialize
      @raw_packet = nil
      @raw_data = nil
      @command = nil
    end

    def decode(bytes)
      @raw_packet = bytes
      @command = bytes[0].ord
      @raw_data = bytes[1..-1]
      subclass = Xbee::class_from_identifier(@command)
      @frame = (subclass and @raw_data ? subclass.new(@raw_data) : nil)
    end

    def decode_args(args)
      return nil unless args and args.length > 0

      value = 0
      args.each_byte do |x|
        value *= 256
        value += x
      end

      value
    end

    def decode_at_value(command, value)
      return nil unless value

      case command
      when 'DB'
        { db: value }
      when '%V'
        { voltage: (value.to_f * 1024 / 1200).round(2) }
      else
        {}
      end
    end

    def data
      ret = {
        command: @command,
        frame: @frame,
        frame_class: @subclass.class.to_s,
      }

      if !@subclass or !@subclass.respond_to?(:fully_decoded)
        ret[:data_hex] = @raw_data.unpack('H*')
      end

      ret
    end
  end

  class UnknownFrameType < APIFrame
    def self.description
      'Unknown frame type'
    end

    def initialize(data)
    end
  end

  class AtCommandFrame < APIFrame
    def fully_decoded ; true ; end

    def self.identifier
      0x08
    end

    def self.description
      'AT Command'
    end

    def initialize(data)
      seq, command, args = data.unpack('Ca2a*')
      value = decode_args(args)

      {
        sequence: seq,
        command: command,
        value: value,
        decoded_value: decode_at_value(command, value),
      }
    end
  end

  class AtCommandQueueParameterValueFrame < APIFrame
    def self.identifier
      0x09
    end

    def self.description
      'AT Command - Queue Parameter Value'
    end

    def initialize(data)
      seq, command, args = data.unpack('Ca2a*')
      value = decode_args(args)

      {
        sequence: seq,
        command: command,
        value: value,
        decoded_value: decode_at_value(command, value),
      }
    end
  end

  class ZigbeeTransmitRequestFrame < APIFrame
    def self.identifier
      0x10
    end

    def self.description
      'ZigBee Transmit Request'
    end

    def initialize(data)
      seq, node64, node16, broadcast_radius, options, app_data = data.unpack('CQ>S>CCa*')

      {
        sequence: seq,
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        broadcast_radius: broadcast_radius,
        transmit_options: options,
        app_data: app_data
      }
    end
  end

  class ExplicitAddressingZigbeeCommandFrame < APIFrame
    attr_reader :seq, :node64, :node16, :source_endpoint, :destination_endpoint
    attr_reader :cluster_id, :profile_id, :broadcast_radius, :options, :app_data

    def self.identifier
      0x11
    end

    def self.description
      'Explicit Addressing ZigBee Command Frame'
    end

    def initialize(data)
      @seq, @node64, @node16, @source_endpoint, @destination_endpoint, @cluster_id, @profile_id, @broadcast_radius, @options, @app_data = data.unpack('CQ>S>CCS>S>CCa*')
    end

    def encode
      [@seq, @node64, @node16, @source_endpoint, @destination_endpoint, @cluster_id, @profile_id, @broadcast_radius, @options, @app_data].pack('CQ>S>CCS>S>CCa*')
    end
  end

  class RemoteAtCommandRequestFrame < APIFrame
    def fully_decoded ; true ; end

    def self.identifier
      0x17
    end

    def self.description
      'Remote AT Command Request'
    end

    def initialize(data)
      seq, node64, node16, options, command, args = data.unpack('CQ>S>Ca2a*')
      value = decode_args(args)

      {
        sequence: seq,
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        command: command,
        options: options,
        value: value,
        decoded_value: decode_at_value(command, value),
      }
    end
  end

  class CreateSourceRouteFrame < APIFrame
    def self.identifier
      0x21
    end

    def self.description
      'Create Source Route'
    end

    def initialize(data)
      seq, node64, node16, options, count, address_data = data.unpack('CQ>S>CCa*')

      addresses = []
      count.times do
        address, address_data = address_data.unpack('S>a*')
        addresses << ('%04x' % address)
      end

      {
        sequence: seq,
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        route_command_options: options,
        address_count: count,
        addresses: addresses,
      }
    end
  end

  class AtCommandResponseFrame < APIFrame
    attr_reader :seq, :command, :status, :value
    def fully_decoded ; true ; end

    def self.identifier
      0x88
    end

    def self.description
      'AT Command Response'
    end

    def initialize(data)
      @seq, @command, @status, args = data.unpack('Ca2Ca*')
      @value = decode_args(args)

      {
        sequence: seq,
        command: command,
        status: status,
        value: value,
        decoded_value: decode_at_value(command, value),
      }
    end
  end

  class ModemStatusFrame < APIFrame
    def self.identifier
      0x8a
    end

    def self.description
      'Modem Status'
    end

    def initialize(data)
      status = data.unpack('C')

      {
        status: status,
      }
    end
  end

  class ZigbeeTransmitStatusFrame < APIFrame
    attr_reader :seq, :node16, :retry_count, :delivery_status, :discovery_status

    def self.identifier
      0x8b
    end

    def self.description
      'ZigBee Transmit Status'
    end

    def initialize(data)
      @seq, @node16, @retry_count, @delivery_status, @discovery_status = data.unpack('CS>CCC')

      {
        sequence: seq,
        node16: '%04x' % node16,
        retry_count: retry_count,
        delivery_status: delivery_status,
        discovery_status: discovery_status,
      }
    end
  end

  class ZigbeeReceivePacketFrame < APIFrame
    def self.identifier
      0x90
    end

    def self.description
      'ZigBee Receive Packet'
    end

    def initialize(data)
      node64, node16, receive_options, app_data = data.unpack('Q>S>Ca*')
      {
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        receive_options: receive_options,
        app_data: app_data
      }
    end
  end

  class ZigbeeExplicitRxIndicatorFrame < APIFrame
    attr_reader :node64, :node16, :source_endpoint, :destination_endpoint
    attr_reader :cluster_id, :profile_id, :broadcast_radius, :receive_options, :app_data
    attr_reader :node64_string, :node16_string, :clusterid_string, :profile_string

    def fully_decoded ; true ; end

    def to_s
      "RECV #{node64_string}/#{node16_string} cl #{clusterid_string} pr #{profile_string} 0x#{source_endpoint.to_s(16)}->0x#{destination_endpoint.to_s(16)}"
    end

    def inspect
      to_s
    end

    def self.identifier
      0x91
    end

    def self.description
      'ZigBee Explicit Rx Indicator'
    end

    def initialize(data)
      @node64, @node16, @source_endpoint, @destination_endpoint, @cluster_id, @profile_id, @receive_options, @app_data = data.unpack('Q>S>CCS>S>Ca*')
      @node64_string = '%016x' % node64
      @node16_string = '%04x' % node16
      @clusterid_string = '%04x' % cluster_id
      @profile_string = '%04x' % profile_id
    end
  end

  class ZigbeeIODataSampleRxFrame < APIFrame
    def self.identifier
      0x92
    end

    def self.description
      'ZigBee IO Data Sample Rx Indicator'
    end

    def initialize(data)
    end
  end

  class XbeeSensorReadIndicatorFrame < APIFrame
    def self.identifier
      0x94
    end

    def self.description
      'XBee Sensor Read Indicator'
    end

    def initialize(data)
    end
  end

  class NodeIdentificationIndicatorFrame < APIFrame
    def fully_decoded ; true ; end

    def self.identifier
      0x95
    end

    def self.description
      'Node Identification Indicator'
    end

    def initialize(data)
      sender64, sender16, options, source16, source64, node_identifier, parent16, device_type, source_event, profile_id, manufacturer_id = data.unpack('Q>S>CS>Q>ZS>CCS>S>')

      {
        sender64: '%016x' % sender64,
        sender16: '%04x' % sender16,
        options: options,
        source16: '%04x' % source16,
        source64: '%016x' % source64,
        node_identifier: node_identifier,
        parent16: '%04x' % parent16,
        device_type: device_type,
        source_event: source_event,
        profile_id: profile_id,
        manufacturer_id: manufacturer_id,
    }
    end
  end

  class RemoteAtCommandResponseFrame < APIFrame
    def fully_decoded ; true ; end

    def self.identifier
      0x97
    end

    def self.description
      'Remote AT Command Response'
    end

    def initialize(data)
      seq, node64, node16, command, status, args = data.unpack('CQ>S>a2Ca*')
      value = decode_args(args)

      {
        sequence: seq,
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        command: command,
        status: status,
        value: value,
        decoded_value: decode_at_value(command, value),
      }
    end
  end

  class OTAFirmwareUpdateStatusFrame < APIFrame
    def self.identifier
      0xa0
    end

    def self.description
      'Over-the-Air Firmware Update Status'
    end

    def initialize(data)
    end
  end

  class RouteRecordIndicatorFrame < APIFrame
    def self.identifier
      0xa1
    end

    def self.description
      'Route Record Indicator'
    end

    def initialize(data)
      node64, node16, options, count, address_data = data.unpack('Q>S>CCa*')

      addresses = []
      count.times do
        address, address_data = address_data.unpack('S>a*')
        addresses << ('%04x' % address)
      end

      {
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        receive_options: options,
        address_count: count,
        addresses: addresses,
      }
    end
  end

  class ManyToOneRouteRequestIndicatorFrame < APIFrame
    def self.identifier
      0xa3
    end

    def self.description
      'Many-to-One Route Request Indicator'
    end

    def initialize(data)
      node64, node16, reserved = data.unpack('Q>S>C')

      {
        node64: '%016x' % node64,
        node16: '%04x' % node16,
        reserved: reserved,
      }
    end
  end
end
