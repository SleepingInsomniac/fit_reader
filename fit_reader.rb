#!/usr/bin/env ruby

# https://developer.garmin.com/fit/protocol/

require 'json'
require 'logger'
require 'byebug'

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

require 'fit'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Fit.logger = Logger.new($stdout, level: Logger::DEBUG)
stream = Fit::Stream.read('2023-01-23-185222 (10-miles).fit')
puts JSON.pretty_generate(stream.messages.map(&:data_expanded))
