# frozen_string_literal: true
require "redis"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"
require "active_support/concern"
require 'active_support/notifications'
require 'active_support/isolated_execution_state'

require_relative "redgraph/version"
require_relative "redgraph/util"
require_relative "redgraph/graph"
require_relative "redgraph/node"
require_relative "redgraph/edge"
require_relative "redgraph/query_response"
require_relative "redgraph/node_model"

module Redgraph
  NOTIFICATIONS_KEY = "redgraph.query".freeze

  class Error < StandardError; end
  class ServerError < Error; end
  class MissingAliasPrefixError < Error
    def message
      "The order clause requires the node/edge alias prefix, ie order('node.foo') instead order('foo')"
    end
  end
  class MissingGraphError < Error
    def message
      "A graph to use is not defined"
    end
  end
end
