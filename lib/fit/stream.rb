# frozen_string_literal: true

require 'json'

require_relative 'header'
require_relative 'record_header'
require_relative 'record_message'

module Fit
  # Represents a collection of Definitions and records for a fit stream as well
  #   as header data and final CRC
  class Stream
    class NoDefinitionError < StandardError
    end

    DEFAULT_PROFILE_PATH = File.join(__dir__, '../../profile.json')

    def self.default_profile
      @default_profile ||= JSON.parse(File.read(DEFAULT_PROFILE_PATH)).freeze
    end

    # [param] path : String
    def self.read(path)
      io = File.open(path, 'rb')
      from_io(io)
    ensure
      io.close
    end

    # [param] io : IO
    def self.from_io(io, profile: default_profile)
      stream = new
      stream.read_header(io)
      length = io.pos + stream.header.data_size

      while io.pos < length
        message = stream.read_message(io)
      end

      crc = io.read(2).unpack('S')
      Fit.logger.debug { "CRC: #{crc}" }

      stream
    end

    attr_accessor :header # : Header
    attr_reader :definitions # : Hash(UInt, DefinitionMessage)
    attr_reader :messages # : Array(DataMessage)

    # [param] profile : Hash
    def initialize(profile: self.class.default_profile)
      @header = nil
      @definitions = {}
      @messages = []
      @profile = profile
      @crc
    end

    # [param] io : IO
    def read_header(io)
      @header = Header.from_stream(io)
    end

    # [param] io : IO
    def read_message(io, &block)
      header_byte = io.read(1).unpack('C').first
      header = RecordHeader.from_byte(header_byte)

      if header.definition?
        DefinitionMessage.from_io(header, io, profile: @profile).tap do |definition|
          Fit.logger.debug { "Defining: #{definition.field_name} - #{definition.field_types}" }
          yield definition if block_given?
          @definitions[header.local_message_type] = definition
        end
      else
        definition = @definitions[header.local_message_type]
        raise NoDefinitionError.new("Could not find definition") unless definition

        DataMessage.from_io(header, definition, io).tap do |message|
          Fit.logger.debug { JSON.pretty_generate(message.data) }
          @messages << message
        end
      end
    end
  end
end
