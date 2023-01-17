class FitStream
  class NoDefinitionError < StandardError
  end

  DEFINITION_SPEC = {
    reserved:              'C',
    architecture:          'C', # 0 Little Endian, 1 Big Endian
    global_message_number: 'S', # Unique to each message
    fields:                'C', # Number of fields in message
  }

  FIELD_DEFINITION_SPEC = {
    field_definition_number: 'C', # 255 is invalid
    size:                    'C', # Size of the field in bytes
    base_type:               'C', # Bitmask with more data
  }

  BASE_TYPES = [
    :enum,
    :int8,
    :uint8,
    :int16,
    :uint16,
    :int32,
    :uint32,
    :string, # null-terminated utf8
    :float32,
    :float64,
    :uint8z,
    :uint16z,
    :uint32z,
    :byte_array,
    :int64,
    :uint64,
    :uint64z,
  ]

  attr_accessor :header # : Header
  attr_reader :definitions # : Hash(UInt, DefinitionMessage)
  attr_reader :messages # : Array(DataMessage)

  def initialize
    @header = nil
    @definitions = {}
    @messages = []
  end

  # [param] io : IO
  def read_message(io)
    header_byte = io.read(1).unpack('C').first
    header = RecordHeader.from_byte(header_byte)
    $logger.debug { header.inspect }

    if header.definition?
      DefinitionMessage.from_io(header, io).tap do |definition|
        @definitions[header.local_message_type] = definition
      end
    else
      definition = @definitions[header.local_message_type]
      raise NoDefinitionError.new("Could not find definition") unless definition

      DataMessage.from_io(header, definition, io).tap do |message|
        @messages << message
      end
    end
  end
end
