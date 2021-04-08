# frozen_string_literal: true
require "redis"

require_relative "redgraph/version"
require_relative "redgraph/graph"

module Redgraph
  class Error < StandardError; end
  class ServerError < Error; end
end
