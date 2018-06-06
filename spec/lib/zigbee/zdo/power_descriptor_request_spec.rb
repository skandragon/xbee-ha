require 'rspec'
require 'spec_helper'

require 'zigbee/zdo/power_descriptor_request'

describe Zigbee::ZDO::PowerDescriptorRequest do
  it "decodes" do
    bytes = [ 0x11, 0x22 ]
    z = Zigbee::ZDO::PowerDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01 ]
    expect {
      Zigbee::ZDO::PowerDescriptorRequest.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes" do
    z = Zigbee::ZDO::PowerDescriptorRequest.new(0x1122)
    expect(z.encode).to eq([ 0x22, 0x11])
  end
end
