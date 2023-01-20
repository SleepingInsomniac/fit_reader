require 'logger'
require_relative 'bin_data'

module Fit
  def self.logger
    @logger ||= Logger.new($stdout, level: Logger::WARN)
  end

  def self.logger=(value)
    @logger = value
  end
end

require_relative 'fit/stream'
