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
              status = bytes.shift | bytes.shift << 8
              extended_status = bytes.shift
              zone_id = bytes.shift
              delay = bytes.shift | bytes.shift << 8
              new(status, zone_id, delay, extended_status)
            end

            def encode
              [
                  status & 0xff, status >> 8,
                  extended_status,
                  zone_id,
                  delay & 0xff, delay >> 8
              ]
            end
          end
        end
      end
    end
  end
end

