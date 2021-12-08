# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    enable_coverage :branch
    add_filter %r{^/test/}
  end
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "redgraph"

require "minitest/autorun"
require "pry"

unless $REDIS_URL = ENV['TEST_REDIS_URL']
  puts "To run the tests you need to define the TEST_REDIS_URL environment variable. Ex:"
  puts "  TEST_REDIS_URL=redis://localhost:6379/0"
  exit(1)
end

module TestHelpers
  private

  def quick_add_node(label:, properties:)
    @graph.add_node(Redgraph::Node.new(label: label, properties: properties))
  end

  def quick_add_edge(type:, src:, dest:, properties:)
    @graph.add_edge(Redgraph::Edge.new(type: type, src: src, dest: dest, properties: properties))
  end
end
