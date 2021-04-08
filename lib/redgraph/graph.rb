# frozen_string_literal: true

module Redgraph
  class Graph
    attr_accessor :connection, :graph_name

    def initialize(graph, redis_options = {})
      @graph_name = graph
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
    end

    # Returns an array of existing graphs
    #
    def list
      @connection.call("GRAPH.LIST")
    end

    # Adds a node
    #
    def add_node(node)
      query("CREATE (n:`#{node.label}` #{quote_hash(node.properties)}) RETURN n")
    end

    private

    def query(cmd)
      data = @connection.call("GRAPH.QUERY", graph_name, cmd, "--compact")
      QueryResponse.new(data)
    end

    def quote_hash(hash)
      out = "{"
      hash.each do |k,v|
        out += "#{k}:#{escape_value(v)}"
      end
      out +"}"
    end

    def escape_value(x)
      case x
      when Integer then x
      else
        "'#{x}'"
      end
    end
  end
end
