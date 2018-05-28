require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/profiles/home_automation/ias/zone_status_change.rb'

describe Zigbee::ZCL::Profiles::HomeAutomation::IAS::ZoneStatusChange do
  it "decodes" do
    bytes = [ 0x11, 0x22, 0x00, 0x01, 0x55, 0x66 ]
    item = Zigbee::ZCL::Profiles::HomeAutomation::IAS::ZoneStatusChange.decode(bytes)
    expect(item.status).to eq(0x2211)
    expect(item.extended_status).to eq(0x00)
    expect(item.zone_id).to eq(0x01)
    expect(item.delay).to eq(0x6655)
  end

  it "encodes" do
    item = Zigbee::ZCL::Profiles::HomeAutomation::IAS::ZoneStatusChange.new(0x1122, 0x33, 0x4455)
    bytes = item.encode
    expect(bytes).to eq([0x22, 0x11, 0x00, 0x33, 0x55, 0x44])
  end
end
