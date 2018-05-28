require 'rspec'
require 'spec_helper'

require 'zigbee/zdo/management_network_update_notify'

describe Zigbee::ZDO::ManagementNetworkUpdateNotify do

  it "decodes" do
    bytes = [
        0x00, 0x00, 0xf8, 0xff, 0x07, 0x18, 0x00, 0x0c,
        0x00, 0x10, 0x54, 0x66, 0x68, 0x66, 0x78, 0x57,
        0x63, 0x60, 0x5e, 0x45, 0x4f, 0x64, 0x60, 0x5e,
        0x5e, 0x4d
    ]
    z = Zigbee::ZDO::ManagementNetworkUpdateNotify.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.scanned_channels).to eq(0x07fff800)
    expect(z.transmissions).to eq(0x0018)
    expect(z.failed_transmissions).to eq(0x000c)
    expect(z.energy).to eq([0x54, 0x66, 0x68, 0x66, 0x78, 0x57, 0x63, 0x60,
                            0x5e, 0x45, 0x4f, 0x64, 0x60, 0x5e, 0x5e, 0x4d])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01 ]
    expect {
      Zigbee::ZDO::ManagementNetworkUpdateNotify.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes" do
    z = Zigbee::ZDO::ManagementNetworkUpdateNotify.new(0x00, 0x07fff800, 0x1234, 0x0123, [ 0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff])
    bytes = [
        0x00, 0x00, 0xf8, 0xff, 0x07, 0x34, 0x12, 0x23,
        0x01, 0x10, 0x00, 0x11, 0x22, 0x33, 0x44, 0x55,
        0x66, 0x77, 0x88, 0x99, 0xaa, 0xbb, 0xcc, 0xdd,
        0xee, 0xff
    ]
    expect(z.encode).to eq(bytes)
  end
end
