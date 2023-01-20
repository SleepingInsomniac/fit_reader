# frozen_string_literal: true

module Fit
  class CompressedTimeStampHeader < RecordHeader
    def initialize(time_offset:, **kwargs)
      super(**kwargs)
      @time_offset = time_offset
    end

    def normal?
      false
    end

    def data?
      true
    end
  end
end
