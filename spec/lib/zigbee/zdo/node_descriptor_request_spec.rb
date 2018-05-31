require 'rspec'
require 'spec_helper'

require 'zigbee/zdo/node_descriptor_request'

describe Zigbee::ZDO::NodeDescriptorRequest do

  it "decodes" do
    bytes = [ 0x11, 0x22 ]
    z = Zigbee::ZDO::NodeDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01 ]
    expect {
      Zigbee::ZDO::NodeDescriptorRequest.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes" do
    z = Zigbee::ZDO::NodeDescriptorRequest.new(0x1122)
    expect(z.encode).to eq([ 0x22, 0x11])
  end
end
