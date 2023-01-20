module BinData
  # Given an array of keys and packed data formats
  # convert bytes into a hash
  #   https://ruby-doc.org/core-3.2.0/packed_data_rdoc.html
  #
  # [param] spec : Hash(Symbol, String)
  # [param] data : String
  # [return] Hash(Symbol, any)
  def self.bytes_to_hash(spec, data)
    spec.keys.zip(data.unpack(spec.values.join)).to_h
  end

  # Converts an array of bit counts into an array of ranges for indexing
  #   ex: [12, 12] => [0...12, 12..24] # Note: exclusive range
  #
  # [param] bit_count_array : Array(UInt)
  # [return] Array(Range(UInt, UInt))
  def self.bit_ranges(bit_count_array)
    # Map the bits field into bit ranges
    low_bit, high_bit = 0, 0
    bit_count_array.map do |bit_count|
      high_bit = low_bit + bit_count
      range = low_bit...high_bit # exclusive range
      low_bit = high_bit
      range
    end
  end
end
