# frozen_string_literal: true

module Fit
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

      new(definition: definition, header: header, data: data)
    end

    # attr_reader :data

    def initialize(definition:, data:, **kwargs)
      super(**kwargs)
      @definition = definition
      @data = data
    end

    def field_profiles
      @field_profiles ||= @definition.profile.dig(
        'messages',
        @definition.gid.to_s,
        'fields'
      )
    end

    def expand(datum, field_profile)
      field_name = field_profile['name']

      expansions = []

      if field_profile['components']&.any?
        _bit_ranges = bit_ranges(field_profile['bits'])
        field_profile['components'].map.with_index do |cfdn, index|
          bit_range = _bit_ranges[index]
          component_profile = field_profiles[cfdn]
          component_datum = datum[bit_range]
          expand(component_datum, component_profile)
        end
      else
        if field_profile['scale'] && field_profile['scale'] > 1
          datum = datum.to_f / field_profile['scale']
        end

        { name: field_profile['name'], value: datum, type: field_profile['type'], units: field_profile['units'] }
      end
    end

    # Converts an array of bit counts into an array of ranges for indexing
    #   ex: [12, 12] => [0..11, 11..23]
    #
    # [param] bit_count_array : Array(UInt)
    # [return] Array(Range(UInt, UInt))
    def bit_ranges(bit_count_array)
      # Map the bits field into bit ranges
      low_bit, high_bit = 0, 0
      bit_count_array.map do |bit_count|
        high_bit = low_bit + bit_count
        range = low_bit...high_bit # exclusive range
        low_bit = high_bit
        range
      end
    end

    def data
      @data.map.with_index do |datum, index|
        field = @definition.fields[index]
        # TODO: Handle missing field profile
        field_profile = field_profiles[field.field_definition_number.to_s]

        expand(datum, field_profile)
      end
    end
  end
end
