require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/write_attributes_response'

describe Zigbee::ZCL::WriteAttributesResponse::Response do
  it "decodes success with NoData type" do
    bytes = [ 0x00, 0x34, 0x12 ]
    z = Zigbee::ZCL::WriteAttributesResponse::Response.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.id).to eq(0x1234)
    expect(z.status).to eq(0x00)
  end
end

describe Zigbee::ZCL::WriteAttributesResponse do
  it "decodes list of attributes" do
    bytes = [ 0x00, 0x02, 0x01 ]
    z = Zigbee::ZCL::WriteAttributesResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.responses.length).to eq(1)
    expect(z.responses.first.id).to eq(0x0102)
    expect(z.responses.first.status).to eq(0x00)
  end

  it "return empty array if no bytes" do
    values = []
    z = Zigbee::ZCL::WriteAttributesResponse.decode(values)
    expect(z.responses).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02 ]
    expect {
      Zigbee::ZCL::WriteAttributesResponse.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes empty list" do
    z = Zigbee::ZCL::WriteAttributesResponse.new([])
    expect(z.encode).to eq([])
  end

  it "encodes single" do
    responses = [
        Zigbee::ZCL::WriteAttributesResponse::Response.new(0x1234, 0x00)
    ]
    z = Zigbee::ZCL::WriteAttributesResponse.new(responses)
    expect(z.encode).to eq([ 0x00, 0x34, 0x12 ])
  end

  it "encodes list" do
    responses = [
        Zigbee::ZCL::WriteAttributesResponse::Response.new(0x1234, 0x00),
        Zigbee::ZCL::WriteAttributesResponse::Response.new(0x9988, 0x01)
    ]
    z = Zigbee::ZCL::WriteAttributesResponse.new(responses)
    expect(z.encode).to eq([ 0x00, 0x34, 0x12, 0x01, 0x88, 0x99 ])
  end
end

describe Zigbee::ZCL::WriteAttributesResponse::Builder do
  it "builds" do
    builder = Zigbee::ZCL::WriteAttributesResponse::Builder.new
    z = builder.responses(0x1234).build
    expect(z.responses).to eq([0x1234])
  end

  it "builds without specifying any ids" do
    builder = Zigbee::ZCL::WriteAttributesResponse::Builder.new
    z = builder.build
    expect(z.responses).to eq([])
  end
end
