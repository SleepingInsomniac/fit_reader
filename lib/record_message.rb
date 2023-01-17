require 'byte_spec'
require 'field_definition'

class RecordMessage
  # [param] header : RecordHeader+
  # [param] gid : UInt16 - Global ID
  def initialize(header:)
    @header = header
  end
end

require 'record_message/definition_message'
require 'record_message/data_message'
