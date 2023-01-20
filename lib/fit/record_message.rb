# frozen_string_literal: true

module Fit
  class RecordMessage
    # [param] header : RecordHeader+
    def initialize(header:)
      @header = header
    end
  end
end

require_relative 'record_message/data_message'
require_relative 'record_message/definition_message'
