require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/default_response'

describe Zigbee::ZCL::DefaultResponse do
  it "decodes" do
    bytes = [ 0x11, 0x22 ]
    item = Zigbee::ZCL::DefaultResponse.decode(bytes)
    expect(item.command).to eq(0x11)
    expect(item.status).to eq(0x22)
  end

  it "encodes" do
    item = Zigbee::ZCL::DefaultResponse.new(0x11, 0x22)
    expect(item.encode).to eq([0x11, 0x22])
  end
end
