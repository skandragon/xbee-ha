require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zdo/simple_descriptor_response'

describe Zigbee::ZDO::SimpleDescriptorResponse do

  it "decodes with input and output clusters" do
    bytes = [ 0x00, 0x01, 0x02, 16, 0x03, 0x05, 0x06, 0x07, 0x08, 0x09, 2, 0x10, 0x11, 0x12, 0x13, 2, 0x20, 0x21, 0x22, 0x23 ]
    z = Zigbee::ZDO::SimpleDescriptorResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.address).to eq(0x0201)
    expect(z.endpoint).to eq(0x03)
    expect(z.profile).to eq(0x0605)
    expect(z.device_id).to eq(0x0807)
    expect(z.device_version).to eq(0x09)
    expect(z.input_clusters).to eq([0x1110, 0x1312])
    expect(z.output_clusters).to eq([0x2120, 0x2322])
  end

  it "decodes with input clusters" do
    bytes = [ 0x00, 0x01, 0x02, 12, 0x03, 0x05, 0x06, 0x07, 0x08, 0x09, 2, 0x10, 0x11, 0x12, 0x13, 0 ]
    z = Zigbee::ZDO::SimpleDescriptorResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.address).to eq(0x0201)
    expect(z.endpoint).to eq(0x03)
    expect(z.profile).to eq(0x0605)
    expect(z.device_id).to eq(0x0807)
    expect(z.device_version).to eq(0x09)
    expect(z.input_clusters).to eq([0x1110, 0x1312])
    expect(z.output_clusters).to eq([])
  end

  it "decodes with output clusters" do
    bytes = [ 0x00, 0x01, 0x02, 12, 0x03, 0x05, 0x06, 0x07, 0x08, 0x09, 0, 2, 0x20, 0x21, 0x22, 0x23 ]
    z = Zigbee::ZDO::SimpleDescriptorResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.address).to eq(0x0201)
    expect(z.endpoint).to eq(0x03)
    expect(z.profile).to eq(0x0605)
    expect(z.device_id).to eq(0x0807)
    expect(z.device_version).to eq(0x09)
    expect(z.input_clusters).to eq([])
    expect(z.output_clusters).to eq([0x2120, 0x2322])
  end


  it "throws if an odd number of bytes remain" do
    values = [ 0x01, 0x05 ]
    expect {
      Zigbee::ZDO::SimpleDescriptorResponse.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "throws if an odd number of bytes remain in descriptor" do
    values = [ 0x01, 0x05, 0x06, 15, 1, 2, 3 ]
    expect {
      Zigbee::ZDO::SimpleDescriptorResponse.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "throws if descriptor is short" do
    values = [ 0x01, 0x05, 0x06, 4, 1, 2, 3, 4 ]
    expect {
      Zigbee::ZDO::SimpleDescriptorResponse.decode(values)
    }.to raise_error(ArgumentError)
  end


  it "encodes with input and output clusters" do
    z = Zigbee::ZDO::SimpleDescriptorResponse.new(0x11, 0x2233, 0x44, 0x5566, 0x7788, 0x05, [ 0x1122, 0x3344], [0x5566, 0x7788])
    expect(z.encode).to eq([ 0x11, 0x33, 0x22, 16, 0x44, 0x66, 0x55, 0x88, 0x77, 0x05, 0x02, 0x22, 0x11, 0x44, 0x33, 0x02, 0x66, 0x55, 0x88, 0x77 ])
  end

  it "encodes with input clusters" do
    z = Zigbee::ZDO::SimpleDescriptorResponse.new(0x11, 0x2233, 0x44, 0x5566, 0x7788, 0x05, [ 0x1122, 0x3344], [])
    expect(z.encode).to eq([ 0x11, 0x33, 0x22, 12, 0x44, 0x66, 0x55, 0x88, 0x77, 0x05, 0x02, 0x22, 0x11, 0x44, 0x33, 0x00 ])
  end

  it "encodes with output clusters" do
    z = Zigbee::ZDO::SimpleDescriptorResponse.new(0x11, 0x2233, 0x44, 0x5566, 0x7788, 0x05, [], [0x5566, 0x7788])
    expect(z.encode).to eq([ 0x11, 0x33, 0x22, 12, 0x44, 0x66, 0x55, 0x88, 0x77, 0x05, 0x00, 0x02, 0x66, 0x55, 0x88, 0x77 ])
  end

end
