require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/write_attributes'

describe Zigbee::ZCL::WriteAttributes::Request do
  it "decodes success with NoData type" do
    bytes = [ 0x34, 0x12, 0x00 ]
    z = Zigbee::ZCL::WriteAttributes::Request.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.id).to eq(0x1234)
    expect(z.data_type).to eq(0x00)
    expect(z.value).to be_nil
  end
end

describe Zigbee::ZCL::WriteAttributes do
  it "decodes list of attributes" do
    bytes = [ 0x02, 0x01, 0x00 ]
    z = Zigbee::ZCL::WriteAttributes.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.requests.length).to eq(1)
    expect(z.requests.first.id).to eq(0x0102)
    expect(z.requests.first.data_type).to eq(0x00)
  end

  it "return empty array if no bytes" do
    values = []
    z = Zigbee::ZCL::WriteAttributes.decode(values)
    expect(z.requests).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02 ]
    expect {
      Zigbee::ZCL::WriteAttributes.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes empty list" do
    z = Zigbee::ZCL::WriteAttributes.new([])
    expect(z.encode).to eq([])
  end

  it "encodes single" do
    requests = [
        Zigbee::ZCL::WriteAttributes::Request.new(0x1234, 0x00, nil)
    ]
    z = Zigbee::ZCL::WriteAttributes.new(requests)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00])
  end

  it "encodes list" do
    responses = [
        Zigbee::ZCL::WriteAttributes::Request.new(0x1234, 0x00, nil),
        Zigbee::ZCL::WriteAttributes::Request.new(0x9988, 0x23, 0x11223344)
    ]
    z = Zigbee::ZCL::WriteAttributes.new(responses)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00, 0x88, 0x99, 0x23, 0x44, 0x33, 0x22, 0x11 ])
  end
end

describe Zigbee::ZCL::WriteAttributes::Builder do
  it "builds" do
    builder = Zigbee::ZCL::WriteAttributes::Builder.new
    z = builder.requests(0x1234).build
    expect(z.requests).to eq([0x1234])
  end

  it "builds without specifying any ids" do
    builder = Zigbee::ZCL::WriteAttributes::Builder.new
    z = builder.build
    expect(z.requests).to eq([])
  end
end
