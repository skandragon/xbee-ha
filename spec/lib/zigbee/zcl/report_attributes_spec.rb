require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/report_attributes'

describe Zigbee::ZCL::ReportAttributes::Response do
  it "decodes success with NoData type" do
    bytes = [ 0x34, 0x12, 0x00 ]
    z = Zigbee::ZCL::ReportAttributes::Response.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.id).to eq(0x1234)
    expect(z.data_type).to eq(0x00)
    expect(z.value).to be_nil
  end
end

describe Zigbee::ZCL::ReportAttributes do
  it "decodes list of attributes" do
    bytes = [ 0x02, 0x01, 0x00 ]
    z = Zigbee::ZCL::ReportAttributes.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.responses.length).to eq(1)
    expect(z.responses.first.id).to eq(0x0102)
    expect(z.responses.first.data_type).to eq(0x00)
  end

  it "decodes list of attributes with data types that have values" do
    bytes = [ 0x88, 0x99, 0x23, 0x44, 0x33, 0x22, 0x11 ]
    z = Zigbee::ZCL::ReportAttributes.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.responses.length).to eq(1)
    expect(z.responses.first.id).to eq(0x9988)
    expect(z.responses.first.data_type).to eq(0x23)
    expect(z.responses.first.value).to eq(0x11223344)
  end

  it "return empty array if no bytes" do
    values = []
    z = Zigbee::ZCL::ReportAttributes.decode(values)
    expect(z.responses).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02, 0x03, 0x04 ]
    expect {
      Zigbee::ZCL::ReportAttributes.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes empty list" do
    z = Zigbee::ZCL::ReportAttributes.new([])
    expect(z.encode).to eq([])
  end

  it "encodes single" do
    responses = [
        Zigbee::ZCL::ReportAttributes::Response.new(0x1234, 0x00, nil)
    ]
    z = Zigbee::ZCL::ReportAttributes.new(responses)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00])
  end

  it "encodes list" do
    responses = [
        Zigbee::ZCL::ReportAttributes::Response.new(0x1234, 0x00, nil),
        Zigbee::ZCL::ReportAttributes::Response.new(0x9988, 0x23, 0x11223344)
    ]
    z = Zigbee::ZCL::ReportAttributes.new(responses)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00, 0x88, 0x99, 0x23, 0x44, 0x33, 0x22, 0x11 ])
  end
end
