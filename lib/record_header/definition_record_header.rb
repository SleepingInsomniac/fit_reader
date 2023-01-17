class DefinitionRecordHeader < RecordHeader
  def initialize(**kwargs)
    super(**kwargs)
  end

  def definition?
    true
  end
end
