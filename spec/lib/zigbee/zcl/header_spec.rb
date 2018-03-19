require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/header'

describe Zigbee::ZCL::Header do
  it "should convert byte to FrameControlField" do
    header = Zigbee::ZCL::Header.new(0, 1, 2)
    expect(header.frame_control).to be_a(Zigbee::ZCL::FrameControlField)
    expect(header.frame_control.encode).to eq([0x00])
    expect(header.transaction_sequence_number).to eq(1)
    expect(header.command_identifier).to eq(2)
  end

  it "should decode without manufacturer specific set" do
    header = Zigbee::ZCL::Header.decode([ 0x00, 0x12, 0x34 ])
    expect(header.frame_control.encode).to eq([0x00])
    expect(header.transaction_sequence_number).to eq(0x12)
    expect(header.command_identifier).to eq(0x34)
  end

  it "should decode with manufacturer specific set" do
    header = Zigbee::ZCL::Header.decode([ 0x04, 0x55, 0x44, 0x12, 0x34 ])
    expect(header.frame_control.encode).to eq([0x04])
    expect(header.manufacturer_code).to eq(0x4455)
    expect(header.transaction_sequence_number).to eq(0x12)
    expect(header.command_identifier).to eq(0x34)
  end

  it "should decode without manufacturer specific set" do
    header = Zigbee::ZCL::Header.new(0, 1, 2)
    expect(header.encode).to eq([0x00, 0x01, 0x02])
  end

  it "should decode with manufacturer specific set" do
    header = Zigbee::ZCL::Header.new(0x04, 1, 2, 0x4455)
    expect(header.encode).to eq([0x04, 0x55, 0x44, 0x01, 0x02])
  end

  it 'catches too little data' do
    expect { Zigbee::ZCL::Header.decode(nil) }.to raise_error(ArgumentError)
    expect { Zigbee::ZCL::Header.decode(0) }.to raise_error(ArgumentError)
    expect { Zigbee::ZCL::Header.decode([]) }.to raise_error(ArgumentError)
  end
end

describe Zigbee::ZCL::Header::Builder do
  it "should build without manufacturer code" do
    builder = Zigbee::ZCL::Header::Builder.new
    header = builder.frame_control(0).transaction_sequence_number(1).command_identifier(2).build
    expect(header.frame_control.encode).to eq([0x00])
    expect(header.transaction_sequence_number).to eq(1)
    expect(header.command_identifier).to eq(2)
    expect(header.encode).to eq([0x00, 0x01, 0x02])
  end

  it "should build without manufacturer code" do
    builder = Zigbee::ZCL::Header::Builder.new
    header = builder.frame_control(0x04).transaction_sequence_number(1).command_identifier(2).manufacturer_code(0x4455).build
    expect(header.frame_control.encode).to eq([0x04])
    expect(header.transaction_sequence_number).to eq(1)
    expect(header.command_identifier).to eq(2)
    expect(header.manufacturer_code).to eq(0x4455)
    expect(header.encode).to eq([0x04, 0x55, 0x44, 0x01, 0x02])
  end
end
