# frozen_string_literal: true

require_relative "graph/node_methods"
require_relative "graph/edge_methods"

module Redgraph
  class Graph
    include NodeMethods
    include EdgeMethods
    include Util

    attr_accessor :connection, :graph_name

    # @example Graph.new("foobar", url: "redis://localhost:6379/0", logger: Logger.new(STDOUT))
    # @param graph_name [String] Name of the graph
    # @param redis_options [Hash] Redis client options
    #
    def initialize(graph_name, redis_options = {})
      @graph_name = graph_name
      @connection = Redis.new(redis_options)
      @module_version = module_version
      raise ServerError unless @module_version
    end

    # Returns the version of the RedisGraph module
    #
    def module_version
      modules = @connection.call("MODULE", "LIST")
      module_graph = modules.detect { |_, name, _, version| name == 'graph' }
      module_graph[3] if module_graph
    end

    # Deletes an existing graph
    #
    def delete
      @connection.call("GRAPH.DELETE", graph_name)
    rescue Redis::CommandError => e
      # Catch exception if the graph was already deleted
      return nil if e.message =~ /ERR Invalid graph operation on empty key/
      raise e
    end

    # @return [Array] Existing graph names
    #
    def list
      @connection.call("GRAPH.LIST")
    end

    # @return [Array] Existing labels
    #
    def labels
      result = _query("CALL db.labels()")
      result.resultset.map(&:values).flatten
    end

    # @return [Array] Existing properties
    #
    def properties
      result = _query("CALL db.propertyKeys()")
      result.resultset.map(&:values).flatten
    end

    # @return [Array] Existing relationship types
    #
    def relationship_types
      result = _query("CALL db.relationshipTypes()")
      result.resultset.map(&:values).flatten
    end

    # You can run custom cypher queries
    def query(cmd)
      _query(cmd).rows
    end

    # @param id [Integer] label id
    # @return [String, nil] label
    #
    def get_label(id)
      @labels ||= labels
      @labels[id] || (@labels = labels)[id]
    end

    # @param id [Integer] property id
    # @return [String, nil] property
    #
    def get_property(id)
      @properties ||= properties
      @properties[id] || (@properties = properties)[id]
    end

    # @param id [Integer] relationship type id
    # @return [String, nil] relationship type
    #
    def get_relationship_type(id)
      @relationship_types ||= relationship_types
      @relationship_types[id] || (@relationship_types = relationship_types)[id]
    end

    private

    def _query(cmd)
      data = @connection.call("GRAPH.QUERY", graph_name, cmd, "--compact")
      QueryResponse.new(data, self)
    end
  end
end
