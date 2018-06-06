require_relative './active_endpoints_request'
require_relative './active_endpoints_response'
require_relative './device_announce'
require_relative './management_network_update_notify'
require_relative './match_descriptor_request'
require_relative './match_descriptor_response'
require_relative './node_descriptor_request'
require_relative './power_descriptor_request'
require_relative './simple_descriptor_request'
require_relative './simple_descriptor_response'

class ProfileZDO
  CLUSTERS = {
      name: 'Zigbee Device Profile',
      clusters: {
          0x0000 => {
              id: 0x0000,
              name: 'Network (16-bit) Address Request',
          },
          0x8000 => {
              id: 0x8000,
              name: 'Network (16-bit) Address Response',
          },
          0x0001 => {
              id: 0x0001,
              name: 'IEEE (64-bit) Address Request',
          },
          0x8001 => {
              id: 0x0801,
              name: 'IEEE (64-bit) Address Response',
          },
          0x0002 => {
              id: 0x0002,
              name: 'Node Descriptor Request',
              cls: Zigbee::ZDO::NodeDescriptorRequest,
          },
          0x8002 => {
              id: 0x08002,
              name: 'Node Descriptor Response',
          },
          0x0003 => {
              id: 0x0003,
              name: 'Power Descriptor Request',
              cls: Zigbee::ZDO::PowerDescriptorRequest,
          },
          0x8003 => {
              id: 0x8003,
              name: 'Power Descriptor Response',
          },
          0x0004 => {
              id: 0x0004,
              name: 'Simple Descriptor Request',
              cls: Zigbee::ZDO::SimpleDescriptorRequest,
          },
          0x8004 => {
              id: 0x8004,
              name: 'Simple Descriptor Response',
              cls: Zigbee::ZDO::SimpleDescriptorResponse,
          },
          0x0005 => {
              id: 0x0005,
              name: 'Active Endpoints Request',
              cls: Zigbee::ZDO::ActiveEndpointsRequest,
          },
          0x8005 => {
              id: 0x8005,
              name: 'Active Endpoints Response',
              cls: Zigbee::ZDO::ActiveEndpointsResponse,
          },
          0x0006 => {
              id: 0x0006,
              name: 'Match Descriptor Request',
              cls: Zigbee::ZDO::MatchDescriptorRequest,
          },
          0x8006 => {
              id: 0x8006,
              name: 'Match Descriptor Response',
              cls: Zigbee::ZDO::MatchDescriptorResponse,
          },
          0x0010 => {
              id: 0x0010,
              name: 'Complex Descriptor Request',
          },
          0x8010 => {
              id: 0x8010,
              name: 'Complex Descriptor Response',
          },
          0x0011 => {
              id: 0x0011,
              name: 'User Descriptor Request',
          },
          0x8011 => {
              id: 0x8011,
              name: 'User Descriptor Response',
          },
          0x0012 => {
              id: 0x0012,
              name: 'Discovery Cache Request',
          },
          0x8012 => {
              id: 0x8012,
              name: 'Discovery Cache Response',
          },
          0x0013 => {
              id: 0x0013,
              name: 'Device Announce',
              cls: Zigbee::ZDO::DeviceAnnounce,
          },
          0x0014 => {
              id: 0x0014,
              name: 'User Descriptor Set',
          },
          0x0015 => {
              id: 0x0015,
              name: 'System Server Discovery Request',
          },
          0x8015 => {
              id: 0x8015,
              name: 'System Server Discovery Response',
          },
          0x0016 => {
              id: 0x0016,
              name: 'Discovery Store Request',
          },
          0x8016 => {
              id: 0x8016,
              name: 'Discovery Store Response',
          },
          0x0017 => {
              id: 0x0017,
              name: 'Node Discovery Store Request',
          },
          0x8017 => {
              id: 0x8017,
              name: 'Node Discovery Store Response',
          },
          0x0018 => {
              id: 0x0018,
              name: 'Power Descriptor Store Request',
          },
          0x8018 => {
              id: 0x8018,
              name: 'Power Descriptor Store Response',
          },
          0x0030 => {
              id: 0x0030,
              name: 'Management Network Discovery Request',
          },
          0x8030 => {
              id: 0x8030,
              name: 'Management Network Discovery Response',
          },
          0x0031 => {
              id: 0x0031,
              name: 'Management LQI (Neighbor Table) Request',
          },
          0x8031 => {
              id: 0x8031,
              name: 'Management LQI (Neighbor Table) Response',
          },
          0x0032 => {
              id: 0x0032,
              name: 'Management Rtg (Routing Table) Request',
          },
          0x8032 => {
              id: 0x8032,
              name: 'Management Rtg (Routing Table) Response',
          },
          0x0034 => {
              id: 0x0034,
              name: 'Management Leave Request',
          },
          0x8034 => {
              id: 0x8034,
              name: 'Management Leave Response',
          },
          0x0036 => {
              id: 0x0036,
              name: 'Management Permit Join Request',
          },
          0x8036 => {
              id: 0x8036,
              name: 'Management Permit Join Response',
          },
          0x0038 => {
              id: 0x0038,
              name: 'Management Network Update Request',
          },
          0x8038 => {
              id: 0x8038,
              name: 'Management Network Update Notify'
          }
      }
  }.freeze
end
