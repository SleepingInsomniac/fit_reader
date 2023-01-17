require 'record_message'

class DataMessage < RecordMessage
  # [param] header : MessageHeader
  # [param] definition : MessageDefinition
  # [param] io : IO
  # [return] RecordMessage+
  def self.from_io(header, definition, io)
    data = definition.fields.map do |field|
      bytes = io.read(field.size)
      datum = bytes.unpack(field.data_template)
      field.compressed? ? datum : datum.first
    end

    new(header: header, data: data)
  end

  def initialize(data:, **kwargs)
    super(**kwargs)
    @data = data
  end
end
