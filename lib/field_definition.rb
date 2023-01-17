require 'byte_spec'

class FieldDefinition
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
    :string,
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

  # [param] bytes : Bytes[3]
  def self.from_bytes(bytes)
    field_data = ByteSpec::bytes_to_hash(FIELD_DEFINITION_SPEC, bytes)
    field_data[:endian_ability]   = field_data[:base_type][7]
    # field_data[:reserved]         = field_data[:base_type][5..6]
    field_data[:base_type_number] = field_data[:base_type][0..4]
    field_data.delete(:base_type)
    new(**field_data)
  end

  attr_reader :field_definition_number
  attr_reader :size
  attr_reader :endian_ability
  # attr_reader :base_type_number
  attr_reader :base_type

  def initialize(field_definition_number:, size:, endian_ability:, base_type_number:)
    @field_definition_number = field_definition_number
    @size = size
    @endian_ability = endian_ability
    # @base_type_number = base_type_number
    @base_type = BASE_TYPES[base_type_number]
  end

  def data_template(endianess = 0)
    case @base_type
    when :enum, :uint8 then 'C'
    when :int8         then 'c'
    when :int16        then 's'
    when :uint16       then 'S'
    when :int32        then 'l'
    when :uint32       then 'L'
    when :string       then 'A*'
    when :float32      then 'f'
    when :float64      then 'd'
    when :int64        then 'q'
    when :uint64       then 'Q'
    when :uint32z      then 'L' * @size
    else
      raise "Unhandled base_type: #{@base_type}"
    end
  end

  def compressed?
    @base_type[-1] == 'z'
  end
end
