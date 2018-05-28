require 'rspec'
require 'spec_helper'

require 'zigbee/zdo/active_endpoints_response'

describe Zigbee::ZDO::ActiveEndpointsResponse do

  it "decodes" do
    bytes = [ 0x00, 0x11, 0x22, 2, 0x99, 0x88 ]
    z = Zigbee::ZDO::ActiveEndpointsResponse.decode(bytes)
    expect(bytes.length).to eq(0)
    expect(z.status).to eq(0x00)
    expect(z.address).to eq(0x2211)
    expect(z.endpoints).to eq([0x99, 0x88])
  end

  it "throws if an odd number of bytes remain" do
    values = [ 0x01 ]
    expect {
      Zigbee::ZDO::ActiveEndpointsResponse.decode(values)
    }.to raise_error(ArgumentError)
  end

  it "encodes" do
    z = Zigbee::ZDO::ActiveEndpointsResponse.new(0x00, 0x1122, [ 0x55, 0x66, 0x77])
    expect(z.encode).to eq([ 0x00, 0x22, 0x11, 3, 0x55, 0x66, 0x77])
  end
end
