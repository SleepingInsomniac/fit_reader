#!/usr/bin/env ruby

# https://developer.garmin.com/fit/protocol/

require 'json'
require 'logger'

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

require 'header'
require 'record_header'
require 'record_message'
require 'fit_stream'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$logger = Logger.new($stdout, :debug)

# Open the FIT file in binary mode
fit_file = File.open('2022-12-13-183027.fit', 'rb')

stream = FitStream.new
stream.header = Header.from_stream(fit_file)

$logger.debug { stream.header.inspect }

length = fit_file.pos + stream.header.data_size

while fit_file.pos < length
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  message = stream.read_message(fit_file)
  pp message
end
