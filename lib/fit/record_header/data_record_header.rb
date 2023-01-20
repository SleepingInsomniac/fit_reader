# frozen_string_literal: true

module Fit
  class DataRecordHeader < RecordHeader
    def initialize(**kwargs)
      super(**kwargs)
    end

    def data?
      true
    end
  end
end
