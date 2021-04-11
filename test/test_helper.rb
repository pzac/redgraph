# frozen_string_literal: true
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch
  add_filter %r{^/test/}
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "redgraph"

require "minitest/autorun"
require "pry"

unless $REDIS_URL = ENV['TEST_REDIS_URL']
  puts "To run the tests you need to define the TEST_REDIS_URL environment variable"
  exit(1)
end
