class DataRecordHeader < RecordHeader
  def initialize(**kwargs)
    super(**kwargs)
  end

  def data?
    true
  end
end
