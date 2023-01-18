class FitStream
  class NoDefinitionError < StandardError
  end

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
