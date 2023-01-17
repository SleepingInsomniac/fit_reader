require 'record_message'

class DefinitionMessage < RecordMessage
  DEFINITION_SPEC = {
    reserved:              'C',
    architecture:          'C', # 0 Little Endian, 1 Big Endian
    global_message_number: 'S', # Unique to each message
    fields:                'C', # Number of fields in message
  }.freeze

  # [param] header : DefinitionRecordHeader
  # [param] io : IO
  def self.from_io(header, io)
    message_hash = ByteSpec::bytes_to_hash(DEFINITION_SPEC, io.read(5))

    fields = message_hash[:fields].times.collect do
      FieldDefinition.from_bytes(io.read(3))
    end

    # TODO: parse developer data, for now, just read over it
    if header.developer?
      $logger.warn { "Skipping developer fields! This may cause errors. Please fix me" }
      dev_field_count = io.read(1).unpack('C').first
      dev_field_count.times { io.read(3) }
    end

    new(
      header: header,
      gid: message_hash[:global_message_number],
      architecture: message_hash[:architecture],
      fields: fields
    )
  end

  attr_reader :gid
  attr_reader :fields

  # [param] gid : UInt - Global ID
  # [param] fields : Array(FieldDefinition)
  def initialize(gid:, fields:, architecture:, **kwargs)
    super(**kwargs)
    @gid = gid
    @architecture = architecture
    @fields = fields
  end
end
