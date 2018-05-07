module ProfileHA
  CLUSTER_BASIC = 0x0000
  CLUSTER_POWER = 0x0001
  CLUSTER_DEVTEMP = 0x0002
  CLUSTER_IDENTIFY = 0x0003
  CLUSTER_GROUPS = 0x0004
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

  CLUSTER_ILLUMINANCE = 0x0401
  CLUSTER_TEMPERATURE = 0x0402
  CLUSTER_PRESSURE = 0x0403
  CLUSTER_FLOW = 0x0404
  CLUSTER_HUMIDITY = 0x0405
  CLUSTER_OCCUPANCY = 0x0406
  CLUSTER_ELECTRICAL = 0x0b04

  # lighting
  CLUSTER_COLORCONTROL = 0x0300
  CLUSTER_BALLAST = 0x0301

  # HVAC
  CLUSTER_PUMP = 0x0200
  CLUSTER_THERMOSTAT = 0x0201
  CLUSTER_FAN = 0x0202
  CLISTER_DEHUMIDIFICATION = 0x0203
  CLUSTER_THERMOSTATUI = 0x0204

  # Closures
  CLUSTER_SHADE = 0x0100
  CLUSTER_DOORLOCK = 0x0101
  CLUSTER_WINDOWCOVERING = 0x0102

  CLUSTER_IASZONE = 0x0500
  CLUSTER_IASACE = 0x0501
  CLUSTER_IASWD = 0x0502



  CLUSTERS = {
    CLUSTER_BASIC: {
      id: CLUSTER_BASIC,
      name: 'BASIC',
      server: {
        attributes: [
          {
            id: 0x0000,
            name: 'ZCLVersion',
            type: :uint8,
            access: :ro,
            default: 0x02,
            mandatory: true
          }, {
            id: 0x0001,
            name: 'ApplicationVersion',
            type: :uint8,
            access: :ro,
            default: 0x00
          }, {
            id: 0x0002,
            name: 'StackVersion',
            type: :uint8,
            access: :ro,
            default: 0x00
          }, {
            id: 0x0003,
            name: 'HWVersion',
            type: :uint8,
            access: :ro,
            default: 0x00
          }, {
            id: 0x0004,
            name: 'ManufacturerName',
            type: :string,
            access: :ro,
            default: ''
          }, {
            id: 0x0005,
            name: 'ModelIdentifier',
            type: :string,
            accesss: :ro,
            default: ''
          }, {
            id: 0x0006,
            name: 'DateCode',
            type: :string,
            access: :ro,
            default: ''
          }, {
            id: 0x0007,
            name: 'PowerSource',
            type: :enum8,
            access: :ro,
            mandatory: true,
            default: 0x00,
            values: [
              { id: 0x00, name: 'Unknown' },
              { id: 0x01, name: 'Mains (single phase)' },
              { id: 0x02, name: 'Mains (3 phase)' },
              { id: 0x03, name: 'Battery' },
              { id: 0x04, name: 'DC Source' },
              { id: 0x05, name: 'Emergency mains constantly powered' },
              { id: 0x06, name: 'Emergency mains and transfer switch' }
            ] },
          {
            id: 0x0010,
            name: 'LocationDescription',
            type: :string,
            access: :rw,
            default: ''
          }, {
            id: 0x0011,
            name: 'PhysicalEnvironment',
            type: :enum8,
            access: :rw,
            default: 0x00
          }, {
            id: 0x0012,
            name: 'DeviceEnabled',
            type: :bool,
            access: :rw,
            default: 0x01
          }, {
            id: 0x0013,
            name: 'AlarmMask',
            type: :map8,
            access: :rw,
            default: 0x00
          }, {
            id: 0x0014,
            name: 'DisableLocalConfig',
            type: :map8,
            access: :rw,
            default: 0x00
          }, {
            id: 0x4000,
            name: 'SWBuildID',
            type: :string,
            access: :ro,
            default: ''
          }
        ],
        commands_received: [
          { id: 0x00, name: 'Reset to Factory Defaults' }
        ],
        commands_generated: []

      },
      client: {
        attributes: [],
        commands_received: [],
        commands_generated: []
      }
    },
    CLUSTER_POWER: {
      id: CLUSTER_POWER,
      name: 'POWER',
      server: {
        attributes: [
          {
            id: 0x0000,
            name: 'MainsVoltage',
            type: :uint16,
            access: :ro
          }, {
            id: 0x0001,
            name: 'MainsFrequency',
            type: :uint8,
            access: :ro
          } # TODO add the others
        ],
        commands_received: [],
        commands_generated: []
      },
      client: {
        attributes: [],
        commands_received: [],
        commands_generated: []
      }
    },
    CLUSTER_DEVTEMP: {
      id: CLUSTER_DEVTEMP,
      name: 'DEVICE TEMPERATURE'
    },
    CLUSTER_IDENTIFY: {
      id: CLUSTER_IDENTIFY,
      name: 'IDENTIFY'
    },
    CLUSTER_ONOFF: {
      id: CLUSTER_ONOFF,
      name: 'ON-OFF'
    },
    CLUSTER_LEVEL: {
      id: CLUSTER_LEVEL,
      name: 'LEVEL'
    },
    CLUSTER_THERMOSTAT: {
      id: CLUSTER_THERMOSTAT,
      name: 'THERMOSTAT'
    },
    CLUSTER_FAN: {
      id: CLUSTER_FAN,
      name: 'FAN'
    },
    CLUSTER_TEMPERATURE: {
      id: CLUSTER_TEMPERATURE,
      name: 'TEMPERATURE'
    },
    CLUSTER_OCCUPANCY: {
      id: CLUSTER_OCCUPANCY,
      name: 'OCCUPANCY'
    },
    0x0b04 => {
      id: 0x0b04,
      name: 'Electrical Measurement'
    },

  }.freeze
  # TODO: need to add Diagnostics
end
