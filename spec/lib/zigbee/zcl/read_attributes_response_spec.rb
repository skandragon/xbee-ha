require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/read_attributes_response'

describe Zigbee::ZCL::ReadAttributesResponse::Response do
  it "decodes non-zero status" do
    bytes = [ 0x34, 0x12, 0x01 ]
    z = Zigbee::ZCL::ReadAttributesResponse::Response.decode(bytes)
    expect(z.id).to eq(0x1234)
    expect(z.status).to eq(0x01)
  end

  it "decodes success with NoData type" do
    bytes = [ 0x34, 0x12, 0x00, 0x00 ]
    z = Zigbee::ZCL::ReadAttributesResponse::Response.decode(bytes)
    expect(z.id).to eq(0x1234)
    expect(z.status).to eq(0x00)
    expect(z.data_type).to eq(0x00)
    expect(z.value).to be_nil
  end
end

describe Zigbee::ZCL::ReadAttributesResponse do
  it "decodes list of attributes" do
    values = [ 0x02, 0x01, 0x00, 0x00 ]
    z = Zigbee::ZCL::ReadAttributesResponse.decode(values)
    expect(z.responses.length).to eq(1)
    expect(z.responses.first.id).to eq(0x0102)
    expect(z.responses.first.status).to eq(0x00)
    expect(z.responses.first.data_type).to eq(0x00)
  end

  it "return empty array if no bytes" do
    values = []
    z = Zigbee::ZCL::ReadAttributesResponse.decode(values)
    expect(z.responses).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02, 0x03, 0x04, 0x05 ]
    expect {
      Zigbee::ZCL::ReadAttributesResponse.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes empty list" do
    z = Zigbee::ZCL::ReadAttributesResponse.new([])
    expect(z.encode).to eq([])
  end

  it "encodes list" do
    responses = [
        Zigbee::ZCL::ReadAttributesResponse::Response.new(0x1234, 0x00, 0x00, nil),
        Zigbee::ZCL::ReadAttributesResponse::Response.new(0x2345, 0x01, nil, nil),
        Zigbee::ZCL::ReadAttributesResponse::Response.new(0x9988, 0x00, 0x23, 0x11223344)
    ]
    z = Zigbee::ZCL::ReadAttributesResponse.new(responses)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00, 0x00, 0x45, 0x23, 0x01 ])
  end
end

describe Zigbee::ZCL::ReadAttributesResponse::Builder do
  it "builds" do
    builder = Zigbee::ZCL::ReadAttributesResponse::Builder.new
    z = builder.responses(0x1234).build
    expect(z.responses).to eq([0x1234])
  end

  it "builds without specifying any ids" do
    builder = Zigbee::ZCL::ReadAttributesResponse::Builder.new
    z = builder.build
    expect(z.responses).to eq([])
  end
end
