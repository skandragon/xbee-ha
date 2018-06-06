require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zdo/device_announce'

describe Zigbee::ZDO::DeviceAnnounce do
  it "decodes" do
    bytes = [
        0x11, 0x22,
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88,
        0xcf
    ]
    z = Zigbee::ZDO::DeviceAnnounce.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
    expect(z.ieee).to eq(0x8877665544332211)
    expect(z.capability).to eq(0xcf)
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x05 ]
    expect {
      Zigbee::ZDO::DeviceAnnounce.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes" do
    z = Zigbee::ZDO::DeviceAnnounce.new(0x1122, 0x1122334455667788, 0xcf)
    expect(z.encode).to eq([ 0x22, 0x11, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0xcf ])
  end

  it "expands flags" do
    responses = [
        [0x80, ['allocate-address']],
        [0x40, ['high-security-mode']],
        [0x08, ['receiver-on-when-idle']],
        [0x04, ['mains-powered']],
        [0x02, ['full-function-device']],
        [0x01, ['alternate-pan-controller']],
        [0x00, []]
    ]

    responses.each do |cap, result|
      z = Zigbee::ZDO::DeviceAnnounce.new(0, 0, cap)
      expect(z.capability_strings).to eq(result)
    end
  end
end
