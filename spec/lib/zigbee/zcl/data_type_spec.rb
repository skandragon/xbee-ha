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

    it "encodes" do
      item = Zigbee::ZCL::DataType::NoData.new(nil).encode
      expect(item).to eq([type])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint8.new(0x99).encode
      expect(item).to eq([type, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint16.new(0x9988).encode
      expect(item).to eq([type, 0x88, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint24.new(0x998877).encode
      expect(item).to eq([type, 0x77, 0x88, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint32.new(0x99887766).encode
      expect(item).to eq([type, 0x66, 0x77, 0x88, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint40.new(0x9988776655).encode
      expect(item).to eq([type, 0x55, 0x66, 0x77, 0x88, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint48.new(0x998877665544).encode
      expect(item).to eq([type, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint56.new(0x99887766554433).encode
      expect(item).to eq([type, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Uint64.new(0x9988776655443322).encode
      expect(item).to eq([type, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99])
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

    it "decodes negative values" do
      bytes = [ type, 0x81, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int8)
      expect(item.value).to eq(-127)
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int8.new(0x99).encode
      expect(item).to eq([type, 0x99])
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

    it "decodes negative values" do
      bytes = [ type, 0x00, 0x81, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int16)
      expect(item.value).to eq(-32512)
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int16.new(1025).encode
      expect(item).to eq([type, 0x01, 0x04])
    end

    it "encodes negative values" do
      item = Zigbee::ZCL::DataType::Int16.new(-32512).encode
      expect(item).to eq([type, 0x00, 0x81])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int24.new(0x123456).encode
      expect(item).to eq([type, 0x56, 0x34, 0x12])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int32.new(0x11223344).encode
      expect(item).to eq([type, 0x44, 0x33, 0x22, 0x11])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int40.new(0x1122334455).encode
      expect(item).to eq([type, 0x55, 0x44, 0x33, 0x22, 0x11])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int48.new(0x112233445566).encode
      expect(item).to eq([type, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int56.new(0x11223344556677).encode
      expect(item).to eq([type, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
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

    it "decodes negative values" do
      bytes = [ type, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x99 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(bytes.length).to eq(1)
      expect(item).to be_a(Zigbee::ZCL::DataType::Int64)
      expect(item.value).to eq(-7383520307673025758)
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

    it "encodes" do
      item = Zigbee::ZCL::DataType::Int64.new(-7383520307673025758).encode
      expect(item).to eq([type, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99])
    end
  end

  describe Zigbee::ZCL::DataType::CharacterString do
    let (:type) { 0x42 }

    it "decodes" do
      bytes = [ type, 0x04, 'a'.ord, 'b'.ord, 'c'.ord, 'd'.ord ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::CharacterString)
      expect(item.value).to eq('abcd')
      expect(item.length).to eq(4)
      expect(item.valid?).to be_truthy
    end

    it "decodes invalid value" do
      bytes = [ type, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::CharacterString)
      expect(item.valid?).to be_falsey
    end

    it "encodes string" do
      item = Zigbee::ZCL::DataType::CharacterString.new('abcd').encode
      expect(item).to eq([type, 0x04, 'a'.ord, 'b'.ord, 'c'.ord, 'd'.ord])
    end

    it "encodes nil as invalid" do
      item = Zigbee::ZCL::DataType::CharacterString.new(nil).encode
      expect(item).to eq([type, 0xff])
    end
  end

  describe Zigbee::ZCL::DataType::EUI64 do
    let (:type) { 0xf0 }

    it "decodes" do
      bytes = [ type, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88 ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::EUI64)
      expect(item.length).to eq(8)
      expect(item.value).to eq(0x8877665544332211)
      expect(item.valid?).to be_truthy
    end

    it "decodes invalid" do
      bytes = [ type, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ]
      item = Zigbee::ZCL::DataType.decode(bytes)
      expect(item).to be_a(Zigbee::ZCL::DataType::EUI64)
      expect(item.length).to eq(8)
      expect(item.valid?).to be_falsey
    end

    it "encodes" do
      item = Zigbee::ZCL::DataType::EUI64.new(0x1122334455667788).encode
      expect(item).to eq([type, 0x88, 0x77, 0x66, 0x55, 0x44, 0x33, 0x22, 0x11])
    end
  end
end
