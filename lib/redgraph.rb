# frozen_string_literal: true
require "redis"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/object/blank"

require_relative "redgraph/version"
require_relative "redgraph/util"
require_relative "redgraph/graph"
require_relative "redgraph/node"
require_relative "redgraph/edge"
require_relative "redgraph/query_response"

module Redgraph
  class Error < StandardError; end
  class ServerError < Error; end
  class MissingAliasPrefixError < Error
    def message
      "The order clause requires the node/edge alias prefix, ie order('node.foo') instead order('foo')"
    end
  end
end
