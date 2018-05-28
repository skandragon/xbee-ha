require 'rspec'
require 'spec_helper'

require 'utils'

describe "utils" do
  class UtilTest
    include ArrayUtils
  end

  let (:util) { UtilTest.new }

  describe "ensure_has_bytes" do
    it "throws for a too short array" do
      expect {
        UtilTest.ensure_has_bytes([], 1)
      }.to raise_error(ArgumentError)

      expect {
        util.ensure_has_bytes([], 1)
      }.to raise_error(ArgumentError)

    end

    it "throws for a non-array" do
      expect {
        UtilTest.ensure_has_bytes(5, 1)
      }.to raise_error(ArgumentError)

      expect {
        util.ensure_has_bytes(5, 1)
      }.to raise_error(ArgumentError)
    end

    it "works for exact size array" do
      expect {
        UtilTest.ensure_has_bytes([1, 2, 3], 3)
      }.to_not raise_error

      expect {
        util.ensure_has_bytes([1, 2, 3], 3)
      }.to_not raise_error
    end
  end

  describe "encode/decode class methods" do
    it "uint8 encode" do
      bytes = UtilTest.encode_uint8(0x12345678)
      expect(bytes).to eq([0x78])
    end

    it "uint8 decode" do
      bytes = [ 0x11, 0x22 ]
      val = UtilTest.decode_uint8(bytes)
      expect(bytes.length).to eq(1)
      expect(val).to eq(0x11)
    end

    it "uint16 encode" do
      bytes = UtilTest.encode_uint16(0x12345678)
      expect(bytes).to eq([0x78, 0x56])
    end

    it "uint16 decode" do
      bytes = [ 0x11, 0x22, 0x33 ]
      val = UtilTest.decode_uint16(bytes)
      expect(bytes.length).to eq(1)
      expect(val).to eq(0x2211)
    end

    it "uint32 encode" do
      bytes = UtilTest.encode_uint32(0x12345678)
      expect(bytes).to eq([0x78, 0x56, 0x34, 0x12])
    end

    it "uint32 decode" do
      bytes = [ 0x11, 0x22, 0x33, 0x44, 0x55]
      val = UtilTest.decode_uint32(bytes)
      expect(bytes.length).to eq(1)
      expect(val).to eq(0x44332211)
    end
  end

  describe "encode/decode instance methods" do
    it "uint8 encode" do
      bytes = util.encode_uint8(0x12345678)
      expect(bytes).to eq([0x78])
    end

    it "uint8 decode" do
      bytes = [ 0x11, 0x22 ]
      val = util.decode_uint8(bytes)
      expect(bytes.length).to eq(1)
      expect(val).to eq(0x11)
    end

    it "uint16 encode" do
      bytes = util.encode_uint16(0x12345678)
      expect(bytes).to eq([0x78, 0x56])
    end

    it "uint16 decode" do
      bytes = [ 0x11, 0x22, 0x33 ]
      val = util.decode_uint16(bytes)
      expect(bytes.length).to eq(1)
      expect(val).to eq(0x2211)
    end

    it "uint32 encode" do
      bytes = util.encode_uint32(0x12345678)
      expect(bytes).to eq([0x78, 0x56, 0x34, 0x12])
    end

    it "uint32 decode" do
      bytes = [ 0x11, 0x22, 0x33, 0x44, 0x55]
      val = util.decode_uint32(bytes)
      expect(bytes.length).to eq(1)
      expect(val).to eq(0x44332211)
    end
  end

  describe "encode/decode lists instance methods" do
    it "uint8 encode" do
      bytes = util.encode_uint8(0x12345678, 0x87654321)
      expect(bytes).to eq([0x78, 0x21])
    end

    it "uint8 decode" do
      bytes = [ 0x11, 0x22 ]
      val = util.decode_uint8(bytes, 2)
      expect(val).to eq([0x11, 0x22])
    end

    it "uint16 encode" do
      bytes = util.encode_uint16(0x12345678, 0x87654321)
      expect(bytes).to eq([0x78, 0x56, 0x21, 0x43])
    end

    it "uint16 decode" do
      bytes = [ 0x11, 0x22, 0x33, 0x44 ]
      val = util.decode_uint16(bytes, 2)
      expect(val).to eq([0x2211, 0x4433])
    end

    it "uint32 encode" do
      bytes = util.encode_uint32(0x12345678, 0x87654321)
      expect(bytes).to eq([0x78, 0x56, 0x34, 0x12, 0x21, 0x43, 0x65, 0x87])
    end

    it "uint32 decode" do
      bytes = [ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88 ]
      val = util.decode_uint32(bytes, 2)
      expect(val).to eq([0x44332211, 0x88776655])
    end
  end
end
