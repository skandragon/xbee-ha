require_relative '../../../../../utils'
require_relative '../../../zcl_command'

module Zigbee
  module ZCL
    module Profiles
      module HomeAutomation
        module IAS
          class ZoneStatusChange < ZCLCommand
            include ArrayUtils

            attr_reader :status, :extended_status, :delay, :zone_id

            def initialize(status, zone_id, delay, extended_status = 0)
              @status = status
              @zone_id = zone_id
              @delay = delay
              @extended_status = extended_status
            end

            def self.decode(bytes)
              ensure_has_bytes(bytes, 6)
              status = decode_uint16(bytes)
              extended_status = decode_uint8(bytes)
              zone_id = decode_uint8(bytes)
              delay = decode_uint16(bytes)
              new(status, zone_id, delay, extended_status)
            end

            def encode
              [
                  encode_uint16(status),
                  encode_uint8(extended_status),
                  encode_uint8(zone_id),
                  encode_uint16(delay)
              ].flatten
            end
          end
        end
      end
    end
  end
end

