module Zigbee
  module ZCL
    module ZCLCommand
      MAP = {
        0x00 => {
          name: 'Read Attributes',
          id: 0x00,
          klass: Zigbee::ZCL::ReadAttributes
        },
        0x01 => 'Read Attributes Response',
        0x02 => 'Write Attributes',
        0x03 => 'Write Attributes Undivided',
        0x04 => 'Write Attributes Response',
        0x05 => 'Write Attributes No Response',
        0x06 => 'Configure Reporting',
        0x07 => 'Configure Reporting Response',
        0x08 => 'Read Reporting Configuration',
        0x09 => 'Read Reporting Configuration Response',
        0x0a => 'Report Attributes',
        0x0b => 'Default Response',
        0x0c => 'Discover Attributes',
        0x0d => 'Discover Attributes Response',
        0x0e => 'Read Attributes Structured',
        0x0f => 'Write Attributes Structured',
        0x10 => 'Write Attributes Structured Response',
        0x11 => 'Discover Commands Received',
        0x12 => 'Discover Commands Received Response',
        0x13 => 'Discover Commands Generated',
        0x14 => 'Discover Commands Generated Response',
        0x15 => 'Discover Attributes Extended',
        0x16 => 'Discover Attributes Extended Response'
      }.freeze
    end
  end
end
