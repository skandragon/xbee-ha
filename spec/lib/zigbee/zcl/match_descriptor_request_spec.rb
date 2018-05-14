require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/match_descriptor_request'

describe Zigbee::ZCL::MatchDescriptorRequest do

  it "decodes with input and output clusters" do
    bytes = [ 0x11, 0x22, 0x33, 0x44, 0x01, 0xaa, 0xbb, 0x01, 0xcc, 0xdd ]
    z = Zigbee::ZCL::MatchDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
    expect(z.profile_id).to eq(0x4433)
    expect(z.input_clusters).to eq([ 0xbbaa ])
    expect(z.output_clusters).to eq([ 0xddcc ])
  end

  it "decodes with input clusters" do
    bytes = [ 0x11, 0x22, 0x33, 0x44, 0x01, 0xaa, 0xbb, 0x00 ]
    z = Zigbee::ZCL::MatchDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
    expect(z.profile_id).to eq(0x4433)
    expect(z.input_clusters).to eq([ 0xbbaa ])
    expect(z.output_clusters).to eq([])
  end

  it "decodes with output clusters" do
    bytes = [ 0x11, 0x22, 0x33, 0x44, 0x00, 0x01, 0xcc, 0xdd ]
    z = Zigbee::ZCL::MatchDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
    expect(z.profile_id).to eq(0x4433)
    expect(z.input_clusters).to eq([])
    expect(z.output_clusters).to eq([ 0xddcc ])
  end

  it "decodes without clusters" do
    bytes = [ 0x11, 0x22, 0x33, 0x44, 0x00, 0x00 ]
    z = Zigbee::ZCL::MatchDescriptorRequest.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.address).to eq(0x2211)
    expect(z.profile_id).to eq(0x4433)
    expect(z.input_clusters).to eq([])
    expect(z.output_clusters).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x02, 0x03, 0x04, 0x05 ]
    expect {
      Zigbee::ZCL::MatchDescriptorRequest.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes with input and output clusters" do
    z = Zigbee::ZCL::MatchDescriptorRequest.new(0x1122, 0x3344, [ 0xaabb ], [ 0xccdd ])
    expect(z.encode).to eq([ 0x22, 0x11, 0x44, 0x33, 0x01, 0xbb, 0xaa, 0x01, 0xdd, 0xcc ])
  end

  it "encodes with input clusters" do
    z = Zigbee::ZCL::MatchDescriptorRequest.new(0x1122, 0x3344, [ 0xaabb ], [])
    expect(z.encode).to eq([ 0x22, 0x11, 0x44, 0x33, 0x01, 0xbb, 0xaa, 0x00 ])
  end

  it "encodes with output clusters" do
    z = Zigbee::ZCL::MatchDescriptorRequest.new(0x1122, 0x3344, [], [ 0xccdd ])
    expect(z.encode).to eq([ 0x22, 0x11, 0x44, 0x33, 0x00, 0x01, 0xdd, 0xcc ])
  end

  it "encodes without clusters" do
    z = Zigbee::ZCL::MatchDescriptorRequest.new(0x1122, 0x3344, [], [])
    expect(z.encode).to eq([ 0x22, 0x11, 0x44, 0x33, 0x00, 0x00 ])
  end
end
