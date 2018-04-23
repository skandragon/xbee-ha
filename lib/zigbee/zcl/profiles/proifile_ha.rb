module ProifileHA
  CLUSTER_BASIC = 0x0000
  CLUSTER_POWER = 0x0001
  CLUSTER_DEVTEMP = 0x0002
  CLUSTER_IDENTIFY = 0x0003
  CLUSTER_GROUPS = x0004
  CLUSTER_SCENES = 0x0005
  CLUSTER_ONOFF = 0x0006
  CLUSTER_ONOFFSWITCH = 0x0007
  CLUSTER_LEVEL = 0x0008
  CLUSTER_ALARMS = 0x0009
  CLUSTER_TIME = 0x000a
  CLUSTER_RSSILOCATION = 0x000b
  CLUSTER_DIAGNOSTICS = 0x0b05
  CLUSTER_POLLCONTROL = 0x0020
  CLUSTER_POWERPROFILE = 0x001a
  CLUSTER_METERID = 0x0b01
  CLUSTER_ANALOGIN = 0x000c
  CLUSTER_ANALOGOUT = 0x000d
  CLUSTER_ANALOGVAL = 0x000e
  CLUSTER_BINARYIN = 0x000f
  CLUSTER_BINARYOUT = 0x0010
  CLUSTER_BINARYVAL = 0x0011
  CLUSTER_MULTISTATEIN = 0x0012
  CLUSTER_MULTISTATEOUT = 0x013
  CLUSTER_MULTISTATEVAL = 0x0014

  CLUSTER_THERMOSTAT = 0x0201
  CLUSTER_FAN = 0x0202
  CLUSTER_TEMPERATURE = 0x0402
  CLUSTER_OCCUPANCY = 0x0406

  CLUSTERS = {
      CLUSTER_BASIC: {
          id: CLUSTER_BASIC,
          name: "BASIC",
          server: {
            attrs: [
                { id: 0x0000, name: "ZCLVersion", type: :uint8, access: :ro, mandatory: true },
                { id: 0x0001, name: 'ApplicationVersion', type: :uint8, access: :ro },
                { id: 0x0002, name: 'StackVersion', type: :uint8, access: :ro },
                { id: 0x0003, name: 'HWVersion', type: :uint8, access: :ro },
                { id: 0x0004, name: 'ManufacturerName', type: :string, access: :ro },
                { id: 0x0005, name: 'ModelIdentifier', type: :string, accesss: :ro },
                { id: 0x0006, name: 'DateCode', type: :string, access: :ro },
                { id: 0x0007, name: 'PowerSource', type: :enum8, access: :ro, mandatory: true,
                  values: [
                      { id: 0x00, name: 'Unknown' },
                      { id: 0x01, name: 'Mains (single phase)' },
                      { id: 0x02, name: 'Mains (3 phase)' },
                      { id: 0x03, name: 'Battery' },
                      { id: 0x04, name: 'DC Source' },
                      { id: 0x05, name: 'Emergency mains constantly powered' },
                      { id: 0x06, name: 'Emergency mains and transfer switch' }
                  ]
                },
                { id: 0x0010, name: 'LocationDescription', type: :string, access: :rw },
                { id: 0x0011, name: 'PhysicalEnvironment', type: :enum8, access: :rw },
                { id: 0x0012, name: 'DeviceEnabled', type: :bool, access: :rw },
                { id: 0x0013, name: 'AlarmMask', type: :map8, access: :rw },
                { id: 0x0014, name: 'DiableLocalConfig', type: :map8, access: :rw },
                { id: 0x4000, name: 'SWBuildID', type: :string, access: :ro }
            ],
            commands_received: [
                { id: 0x00, name: 'Reset to Factory Defaults' }
            ],
            commands_generated: [],

          },
          client: {
              attrs: [],
              commands_received: [],
              commands_generated: [],
          }
      },
      CLUSTER_POWER: { id: CLUSTER_POWER, name: 'POWER' },
      CLUSTER_DEVTEMP: { id: CLUSTER_DEVTEMP, name: 'DEVICE TEMPERATURE' },
      CLUSTER_IDENTIFY: { id: CLUSTER_IDENTIFY, name: 'IDENTIFY' },
      CLUSTER_ONOFF: { id: CLUSTER_ONOFF, name: "ON-OFF" },
      CLUSTER_LEVEL: { id: CLUSTER_LEVEL, name: "LEVEL" },
      CLUSTER_THERMOSTAT: { id: CLUSTER_THERMOSTAT, name: "THERMOSTAT" },
      CLUSTER_FAN: { id: CLUSTER_FAN, name: "FAN" },
      CLUSTER_TEMPERATURE: { id: CLUSTER_TEMPERATURE, name: "TEMPERATURE" },
      CLUSTER_OCCUPANCY: { id: CLUSTER_OCCUPANCY, name: "OCCUPANCY" }
  }
end