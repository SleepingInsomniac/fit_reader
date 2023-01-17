# frozen_string_literal: true

# A `RecordHeader` is the 1 byte of data preceding a record
#
class RecordHeader
  # Create the appropriate header instance from the byte data
  #
  # [param] byte : UIint8
  # [return] DefinitionRecordHeader | DataRecordHeader | CompressedTimeStampHeader
  def self.from_byte(byte)
    if byte[7] == 0
      # Normal Header
      if byte[6] == 1
        # Definition Message
        DefinitionRecordHeader.new(
          local_message_type: byte[0..3],
          developer: byte[5] == 1
        )
      else
        # Data Message
        DataRecordHeader.new(
          local_message_type: byte[0..3],
          developer: byte[5] == 1
        )
      end
    else
      # Compressed Timestamp Header
      CompressedTimeStampHeader.new(
        local_message_type: byte[5..6],
        time_offset:        byte[0..4]
      )
    end
  end

  attr_reader :local_message_type

  # This should not be called directly as this is an abstract class
  #
  # [param] local_message_type : UInt8
  # [param] developer : Bool
  def initialize(local_message_type:, developer: false)
    @local_message_type = local_message_type
    @developer = developer
  end

  def normal?
    true
  end

  def definition?
    false
  end

  def data?
    false
  end

  def developer?
    @developer
  end
end

require 'record_header/data_record_header'
require 'record_header/definition_record_header'
require 'record_header/compressed_timestamp_header'
