require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/read_attributes'

describe Zigbee::ZCL::ReadAttributes do
  it "decodes list of attributes" do
    values = [ 0x02, 0x01, 0x04, 0x03, 0x06, 0x05 ]
    z = Zigbee::ZCL::ReadAttributes.decode(values)
    expect(z.attribute_ids).to eq([0x0102, 0x0304, 0x0506])
  end

  it "return empty array if no bytes" do
    values = []
    z = Zigbee::ZCL::ReadAttributes.decode(values)
    expect(z.attribute_ids).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02, 0x03, 0x04, 0x05 ]
    expect {
      Zigbee::ZCL::ReadAttributes.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes empty list" do
    z = Zigbee::ZCL::ReadAttributes.new([])
    expect(z.encode).to eq([])
  end

  it "encodes list" do
    z = Zigbee::ZCL::ReadAttributes.new([0x1122, 0x3344])
    expect(z.encode).to eq([ 0x22, 0x11, 0x44, 0x33 ])
  end
end
