# frozen_string_literal: true

class Crc16
  CRC_TABLE = [
    0x0000, 0xCC01, 0xD801, 0x1400, 0xF001, 0x3C00, 0x2800, 0xE401,
    0xA001, 0x6C00, 0x7800, 0xB401, 0x5000, 0x9C01, 0x8801, 0x4400
  ]

  # [param] io : IO
  # [return] Bool
  def self.check(io, expected, length: nil)
    length ||= io.size
    crc_calculator = new
    pos = io.pos

    until io.eof? || length && (io.pos - pos >= length)
      byte = io.read(1).unpack('C').first
      crc_calculator.update(byte)
    end

    (crc_calculator.value == expected).tap do |valid|
      message = "CRC16 #{ valid ? 'valid' : 'invalid' }: " \
                "expected: 0x#{expected.to_s(16)}, " \
                "actual: 0x#{crc_calculator.value.to_s(16)}"

      valid ? Fit.logger.debug { message } : Fit.logger.warn { message }
    end
  end

  attr_reader :value

  def initialize
    @value = 0
  end

  # [param] byte : UInt8
  def update(byte)
    # compute checksum of lower four bits of byte
    tmp = CRC_TABLE[@value & 0xF]
    @value = (@value >> 4) & 0x0FFF
    @value = @value ^ tmp ^ CRC_TABLE[byte & 0xF];

    # now compute checksum of upper four bits of byte
    tmp = CRC_TABLE[@value & 0xF]
    @value = (@value >> 4) & 0x0FFF
    @value = @value ^ tmp ^ CRC_TABLE[(byte >> 4) & 0xF]

    @value
  end
end
