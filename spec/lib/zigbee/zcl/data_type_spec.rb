require 'rspec'
require 'spec_helper'

require 'zigbee/zcl/data_type'

describe Zigbee::ZCL::DataType do
  describe Zigbee::ZCL::DataType::NoData do
    let(:type) { 0x00 }

    it "decodes" do
      bytes = [ type, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::NoData)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true
    end
  end

  describe Zigbee::ZCL::DataType::Uint8 do
    let(:type) { 0x20 }

    it "decodes" do
      bytes = [ 0x20, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint8)
      expect(item.value).to eq(0x11)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ 0x20, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ 0x20, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ 0x20 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint16 do
    let(:type) { 0x21 }

    it "decodes" do
      bytes = [ type, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint16)
      expect(item.value).to eq(0x1122)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint24 do
    let(:type) { 0x22 }

    it "decodes" do
      bytes = [ type, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint24)
      expect(item.value).to eq(0x112233)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint32 do
    let(:type) { 0x23 }

    it "decodes" do
      bytes = [ type, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint32)
      expect(item.value).to eq(0x11223344)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint40 do
    let(:type) { 0x24 }

    it "decodes" do
      bytes = [ type, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint40)
      expect(item.value).to eq(0x1122334455)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint48 do
    let(:type) { 0x25 }

    it "decodes" do
      bytes = [ type, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint48)
      expect(item.value).to eq(0x112233445566)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint56 do
    let(:type) { 0x26 }

    it "decodes" do
      bytes = [ type, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint56)
      expect(item.value).to eq(0x11223344556677)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Uint64 do
    let(:type) { 0x27 }

    it "decodes" do
      bytes = [ type, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Uint64)
      expect(item.value).to eq(0x1122334455667788)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  #
  # Signed integer
  #

  describe Zigbee::ZCL::DataType::Int8 do
    let(:type) { 0x28 }

    it "decodes" do
      bytes = [ type, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int8)
      expect(item.value).to eq(0x11)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int16 do
    let(:type) { 0x29 }

    it "decodes" do
      bytes = [ type, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int16)
      expect(item.value).to eq(0x1122)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int24 do
    let(:type) { 0x2a }

    it "decodes" do
      bytes = [ type, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int24)
      expect(item.value).to eq(0x112233)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int32 do
    let(:type) { 0x2b }

    it "decodes" do
      bytes = [ type, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int32)
      expect(item.value).to eq(0x11223344)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x00, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int40 do
    let(:type) { 0x2c }

    it "decodes" do
      bytes = [ type, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int40)
      expect(item.value).to eq(0x1122334455)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int48 do
    let(:type) { 0x2d }

    it "decodes" do
      bytes = [ type, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int48)
      expect(item.value).to eq(0x112233445566)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int56 do
    let(:type) { 0x2e }

    it "decodes" do
      bytes = [ type, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int56)
      expect(item.value).to eq(0x11223344556677)
      expect(bytes.length).to eq(1)

      bytes = [ type, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int56)
      expect(item.value).to eq(-1)
      expect(bytes.length).to eq(1)

    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

  describe Zigbee::ZCL::DataType::Int64 do
    let(:type) { 0x2f }

    it "decodes" do
      bytes = [ type, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int64)
      expect(item.value).to eq(0x1122334455667788)
      expect(bytes.length).to eq(1)
    end

    it "handles invalid values" do
      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be true

      bytes = [ type, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item.valid?).to be false
    end

    it "throws for not enough data" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77 ]
      expect {
        Zigbee::ZCL::DataType.decode(bytes)
      }.to raise_error(ArgumentError)
    end
  end

end
