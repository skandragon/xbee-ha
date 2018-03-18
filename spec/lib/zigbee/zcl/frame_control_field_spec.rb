require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/header'

describe Zigbee::ZCL::FrameControlField do
  it 'should render global, from client, no manufacturer' do
    control_field = Zigbee::ZCL::FrameControlField.new(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL, 0, 0, 0)
    expect(control_field.frame_type).to eq(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL)
    expect(control_field.encode).to eq([0x00])
  end
end

describe Zigbee::ZCL::FrameControlField::Builder do
  it 'should render global, from client, no manufacturer' do
    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.build
    expect(control_field.frame_type).to eq(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL)
    expect(control_field.encode).to eq([0x00])
  end

  it 'should create via from_a' do
    source = [ 0x00 ]
    control_field = Zigbee::ZCL::FrameControlField.decode(source)
    expect(control_field.encode).to eq([0x00])
    expect(source.length).to eq(0)

    source = [ 0x10 ]
    control_field = Zigbee::ZCL::FrameControlField.decode(source)
    expect(control_field.encode).to eq([0x10])
    expect(control_field.disable_default_response).to eq(1)
    expect(source.length).to eq(0)
  end

  it 'sets frame_type' do
    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.frame_type(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL).build
    expect(control_field.frame_type).to eq(Zigbee::ZCL::FrameControlField::FRAME_TYPE_GLOBAL)
    expect(control_field.encode).to eq([0x00])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.frame_type(Zigbee::ZCL::FrameControlField::FRAME_TYPE_LOCAL).build
    expect(control_field.frame_type).to eq(Zigbee::ZCL::FrameControlField::FRAME_TYPE_LOCAL)
    expect(control_field.encode).to eq([0x01])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.frame_type(2).build
    expect(control_field.frame_type).to eq(2)
    expect(control_field.encode).to eq([0x02])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.frame_type(3).build
    expect(control_field.frame_type).to eq(3)
    expect(control_field.encode).to eq([0x03])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.frame_type(4).build # out of bounds
    expect(control_field.frame_type).to eq(0)
    expect(control_field.encode).to eq([0x00])
  end

  it 'sets manufacturer_specific' do
    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.manufacturer_specific(0).build
    expect(control_field.manufacturer_specific).to eq(0)
    expect(control_field.encode).to eq([0x00])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.manufacturer_specific(1).build
    expect(control_field.manufacturer_specific).to eq(1)
    expect(control_field.encode).to eq([0x04])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.manufacturer_specific(2).build # out of bounds
    expect(control_field.manufacturer_specific).to eq(0)
    expect(control_field.encode).to eq([0x00])
  end

  it 'sets direction' do
    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.direction(0).build
    expect(control_field.direction).to eq(0)
    expect(control_field.encode).to eq([0x00])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.direction(1).build
    expect(control_field.direction).to eq(1)
    expect(control_field.encode).to eq([0x08])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.direction(2).build # out of bounds
    expect(control_field.direction).to eq(0)
    expect(control_field.encode).to eq([0x00])
  end

  it 'sets disable_default_response' do
    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.disable_default_response(0).build
    expect(control_field.disable_default_response).to eq(0)
    expect(control_field.encode).to eq([0x00])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.disable_default_response(1).build
    expect(control_field.disable_default_response).to eq(1)
    expect(control_field.encode).to eq([0x10])

    builder = Zigbee::ZCL::FrameControlField::Builder.new
    control_field = builder.disable_default_response(2).build # out of bounds
    expect(control_field.disable_default_response).to eq(0)
    expect(control_field.encode).to eq([0x00])
  end

  it 'catches too little data' do
    expect { Zigbee::ZCL::FrameControlField.decode(nil) }.to raise_error(ArgumentError)
    expect { Zigbee::ZCL::FrameControlField.decode(0) }.to raise_error(ArgumentError)
    expect { Zigbee::ZCL::FrameControlField.decode([]) }.to raise_error(ArgumentError)
  end
end
