require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/read_attributes_response'

describe Zigbee::ZCL::ReadAttributesResponse do
  it "decodes" do
    data = [ 0x34, 0x12, 0x21, 0x43 ]
    response = Zigbee::ZCL::ReadAttributesResponse.decode(data)
    expect(response.responses).to eq([ 0x1234, 0x4321 ])
  end
end
