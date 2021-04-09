# frozen_string_literal: true
require "redis"

require_relative "redgraph/version"
require_relative "redgraph/graph"
require_relative "redgraph/node"
require_relative "redgraph/edge"
require_relative "redgraph/query_response"

module Redgraph
  class Error < StandardError; end
  class ServerError < Error; end
end
