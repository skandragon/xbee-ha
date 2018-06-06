require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zdo/simple_descriptor_request'

describe Zigbee::ZDO::SimpleDescriptorRequest do
  it "decodes" do
    bytes = [ 0x11, 0x22, 0x33 ]
    z = Zigbee::ZDO::SimpleDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
    expect(z.endpoint).to eq(0x33)
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x05 ]
    expect {
      Zigbee::ZDO::SimpleDescriptorRequest.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes" do
    z = Zigbee::ZDO::SimpleDescriptorRequest.new(0x1122, 0x44)
    expect(z.encode).to eq([ 0x22, 0x11, 0x44 ])
  end
end
