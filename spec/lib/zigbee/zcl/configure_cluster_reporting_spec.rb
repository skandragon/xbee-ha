require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/constants'
require 'zigbee/zcl/configure_cluster_reporting'

describe Zigbee::ZCL::ConfigureClusterReporting::Record do
  it "decodes direction 0" do
    bytes = [ 0x00, 0x12, 0x34, 0x21, 0x11, 0x22, 0x33, 0x44, 0x23, 0x01]
    z = Zigbee::ZCL::ConfigureClusterReporting::Record.decode(bytes)

    expect(z.direction).to eq(0x00)
    expect(z.attribute).to eq(0x3412)
    expect(z.data_type).to eq(0x21)
    expect(z.minimum).to eq(0x2211)
    expect(z.maximum).to eq(0x4433)
    expect(z.reportable_change).to eq(0x0123)
    expect(z.timeout).to be_nil
    expect(bytes.length).to eq(0)
  end

  it "encodes direction 1" do
    bytes = [ 0x01, 0x12, 0x34, 0x21, 0x11]
    z = Zigbee::ZCL::ConfigureClusterReporting::Record.decode(bytes)

    expect(z.direction).to eq(0x01)
    expect(z.attribute).to eq(0x3412)
    expect(z.data_type).to be_nil
    expect(z.minimum).to be_nil
    expect(z.maximum).to be_nil
    expect(z.reportable_change).to be_nil
    expect(z.timeout).to eq(0x1121)
    expect(bytes.length).to eq(0)
  end

  it "encodes direction 0" do
    z = Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x00, 0x1234, 0x23, 0x1122, 0x3344, 0x99887766, nil)
    expect(z.encode).to eq([0x00, 0x34, 0x12, 0x23, 0x22, 0x11, 0x44, 0x33, 0x66, 0x77, 0x88, 0x99])
  end

  it "encodes direction 1" do
    z = Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x01, 0x1234, nil, nil, nil, nil, 0x9988)
    expect(z.encode).to eq([0x01, 0x34, 0x12, 0x88, 0x99])
  end
end

describe Zigbee::ZCL::ConfigureClusterReporting do
  it "decodes two records" do
    records = [
        Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x01, 0x1234, nil, nil, nil, nil, 0x9988).encode,
        Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x01, 0x4321, nil, nil, nil, nil, 0x5544).encode
    ].flatten
    z = Zigbee::ZCL::ConfigureClusterReporting.decode(records)
    expect(z.records.count).to be(2)
    expect(records).to be_empty
  end

  it "encodes two records" do
    r1 = Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x01, 0x1234, nil, nil, nil, nil, 0x9988)
    r2 = Zigbee::ZCL::ConfigureClusterReporting::Record.new(0x01, 0x4321, nil, nil, nil, nil, 0x5544)
    expected = [ r1.encode, r2.encode ].flatten

    z = Zigbee::ZCL::ConfigureClusterReporting.new([ r1, r2 ])
    expect(z.encode).to eq(expected)
  end

end
