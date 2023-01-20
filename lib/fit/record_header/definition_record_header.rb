# frozen_string_literal: true

module Fit
  class DefinitionRecordHeader < RecordHeader
    def initialize(**kwargs)
      super(**kwargs)
    end

    def definition?
      true
    end
  end
end
