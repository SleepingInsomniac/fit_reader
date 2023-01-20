# frozen_string_literal: true

require_relative "../field_definition"

module Fit
  class DefinitionMessage < RecordMessage
    DEFINITION_SPEC = {
      reserved:              'C',
      architecture:          'C', # 0 Little Endian, 1 Big Endian
      global_message_number: 'S', # Unique to each message
      fields:                'C', # Number of fields in message
    }.freeze

    # [param] header : DefinitionRecordHeader
    # [param] io : IO
    # [param] profile : Hash
    def self.from_io(header, io, profile:)
      message_hash = BinData.bytes_to_hash(DEFINITION_SPEC, io.read(5))

      fields = message_hash[:fields].times.collect do
        FieldDefinition.from_bytes(io.read(3))
      end

      # TODO: parse developer data, for now, just read over it
      if header.developer?
        Fit.logger.warn { "Skipping developer fields! This may cause errors. Please fix me" }
        dev_field_count = io.read(1).unpack('C').first
        dev_field_count.times { io.read(3) }
      end

      new(
        header: header,
        gid: message_hash[:global_message_number],
        architecture: message_hash[:architecture],
        fields: fields,
        profile: profile
      )
    end

    attr_reader :gid
    attr_reader :architecture
    attr_reader :fields
    attr_reader :profile

    # [param] gid : UInt - Global ID
    # [param] architecture : UInt - Endianness
    # [param] fields : Array(FieldDefinition)
    # [param] profile : Hash
    def initialize(gid:, fields:, architecture:, profile:, **kwargs)
      super(**kwargs)
      @gid = gid
      @architecture = architecture
      @fields = fields
      @profile = profile
    end

    def field_name
      @profile['messages'][@gid.to_s]['name']
    end

    def field_types
      @fields.map(&:base_type)
    end
  end
end
