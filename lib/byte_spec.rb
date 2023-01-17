module ByteSpec
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
end
