require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/match_descriptor_response'

describe Zigbee::ZCL::MatchDescriptorResponse do

  it "decodes with endpoint list" do
    bytes = [ 0x00, 0x11, 0x22, 0x02, 0x55, 0x66 ]
    z = Zigbee::ZCL::MatchDescriptorResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.address).to eq(0x2211)
    expect(z.endpoints).to eq([ 0x55, 0x66 ])
  end

  it "decodes without endpoints" do
    bytes = [ 0x00, 0x11, 0x22, 0x00 ]
    z = Zigbee::ZCL::MatchDescriptorResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.address).to eq(0x2211)
    expect(z.endpoints).to eq([])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x00, 0x02, 0x03, 0x04 ]
    expect {
      Zigbee::ZCL::MatchDescriptorResponse.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes with endpoints" do
    z = Zigbee::ZCL::MatchDescriptorResponse.new(0x00, 0x1122, [ 0x55, 0x66 ])
    expect(z.encode).to eq([ 0x00, 0x22, 0x11, 0x02, 0x55, 0x66 ])
  end

  it "encodes without endpoints" do
    z = Zigbee::ZCL::MatchDescriptorResponse.new(0x00, 0x1122, [])
    expect(z.encode).to eq([ 0x00, 0x22, 0x11, 0x00 ])
  end
end
