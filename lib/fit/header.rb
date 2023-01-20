# frozen_string_literal: true

module Fit
  # A FIT file header
  class Header
    class UnknownFormat < StandardError
    end

    # I don't know if this is correct
    SPEC_12 = {
      protocol_version: 'C',
      profile_version:  'C',
      data_size:        'S',
      data_type:        'a4',
      crc:              'S',
    }.freeze

    # 14 bytes is the "modern preferred format"
    SPEC_14 = {
      protocol_version: 'C',  # 8-bit unsigned integer
      profile_version:  'S',  # 16-bit unsigned integer, native-endian (LSB)
      data_size:        'L',  # 32-bit unsigned integer, native-endian (LSB)
      data_type:        'a4', # Should contain ascii '.FIT'
      crc:              'S',  # 16-bit unsigned integer, native-endian (LSB)
    }.freeze

    # [param] stream : IO
    # [return] Header
    def self.from_stream(stream)
      header_size = stream.read(1).unpack('C').first
      header_bytes = stream.read(header_size - 1)
      from_bytes(header_bytes)
    end

    # [param] bytes : String
    # [return] Header
    def self.from_bytes(bytes)
      # bytes length will be 1 less than specified since the first byte
      #   contains the length of the header.
      data_hash = case bytes.length
      when 11
        Fit.logger.debug { "Parsing 12 byte header" }
        BinData.bytes_to_hash(SPEC_12, bytes)
      when 13
        Fit.logger.debug { "Parsing 14 byte header" }
        BinData.bytes_to_hash(SPEC_14, bytes)
      else
        Fit.logger.debug { "Don't know how to parse unknown byte length header." }
        raise UnknownFormat.new("Cannot read header of size #{bytes.size} bytes")
      end

      Fit.logger.debug { JSON.pretty_generate(data_hash) }

      new(**data_hash)
    end

    attr_reader :protocol_version
    attr_reader :profile_version
    attr_reader :data_size
    attr_reader :data_type
    attr_reader :crc

    # [param] protocol_version : UInt8
    # [param] profile_version : UInt8
    # [param] data_size : UInt16
    # [param] data_type : String
    # [param] crc : Uint16
    def initialize(protocol_version:, profile_version:, data_size:, data_type:, crc:)
      @protocol_version = protocol_version
      @profile_version = profile_version
      @data_size = data_size
      @data_type = data_type
      @crc = crc
    end
  end
end
