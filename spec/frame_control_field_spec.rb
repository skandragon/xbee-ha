require 'rspec'

require 'zigbee/zcl/header'

describe Zigbee::ZCL::FrameControlField do

  it 'should render global, from client, no manufacturer' do
    control_field = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL, 0)
    expect(control_field.value).to eq(0)
  end
end
