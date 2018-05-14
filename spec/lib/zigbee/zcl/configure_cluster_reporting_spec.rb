require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/configure_cluster_reporting'

describe Zigbee::ZCL::ConfigureClusterReporting do
  it "decodes list of attributes" do
    bytes = [ 0x02, 0x01, 0x00, 0x00 ]
    z = Zigbee::ZCL::ConfigureClusterReporting.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.responses.length).to eq(1)
    expect(z.responses.first.id).to eq(0x0102)
    expect(z.responses.first.status).to eq(0x00)
    expect(z.responses.first.data_type).to eq(0x00)
  end

  it "decodes list of attributes with data types that have values" do
    bytes = [ 0x88, 0x99, 0x00, 0x23, 0x44, 0x33, 0x22, 0x11 ]
    z = Zigbee::ZCL::ConfigureClusterReporting.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.responses.length).to eq(1)
    expect(z.responses.first.id).to eq(0x9988)
    expect(z.responses.first.status).to eq(0x00)
    expect(z.responses.first.data_type).to eq(0x23)
    expect(z.responses.first.value).to eq(0x11223344)
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02, 0x03, 0x04, 0x05 ]
    expect {
      Zigbee::ZCL::ConfigureClusterReporting.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes empty list" do
    z = Zigbee::ZCL::ConfigureClusterReporting.new([])
    expect(z.encode).to eq([])
  end

  it "encodes single" do
    responses = [
        Zigbee::ZCL::ConfigureClusterReporting::Response.new(0x1234, 0x00, 0x00, nil)
    ]
    z = Zigbee::ZCL::ConfigureClusterReporting.new(responses)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00, 0x00])
  end

  it "encodes list" do
    responses = [
        Zigbee::ZCL::ConfigureClusterReporting::Response.new(0x1234, 0x00, 0x00, nil),
        Zigbee::ZCL::ConfigureClusterReporting::Response.new(0x2345, 0x01, nil, nil),
        Zigbee::ZCL::ConfigureClusterReporting::Response.new(0x9988, 0x00, 0x23, 0x11223344)
    ]
    z = Zigbee::ZCL::ConfigureClusterReporting.new(responses)
    expect(z.encode).to eq([ 0x34, 0x12, 0x00, 0x00, 0x45, 0x23, 0x01, 0x88, 0x99, 0x00, 0x23, 0x44, 0x33, 0x22, 0x11 ])
  end
end
