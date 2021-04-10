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
    rescue Redis::CommandError => e
      # Catch exception if the graph was already deleted
      return nil if e.message =~ /ERR Invalid graph operation on empty key/
      raise e
    end

    # Returns an array of existing graphs
    #
    def list
      @connection.call("GRAPH.LIST")
    end

    # Returns an array of existing labels
    #
    def labels
      result = query("CALL db.labels()")
      result.resultset.map(&:values).flatten
    end

    # Returns an array of existing properties
    #
    def properties
      result = query("CALL db.propertyKeys()")
      result.resultset.map(&:values).flatten
    end

    # Adds a node. If successul it returns the created object, otherwise false
    #
    def add_node(node)
      result = query("CREATE (n:`#{node.label}` #{quote_hash(node.properties)}) RETURN ID(n)")
      return false if result.stats[:nodes_created] != 1
      id = result.resultset.first["ID(n)"]
      node.id = id
      node
    end

    def find_node_by_id(id)
      result = query("MATCH (node) WHERE ID(node) = #{id} RETURN node")
      return nil if result.resultset.empty?
      (node_id, labels, properties) = result.resultset.first["node"]
      attrs = {}

      properties.each do |(index, type, value)|
        attrs[get_property(index)] = value
      end
      Node.new(label: get_label(labels.first), properties: attrs).tap do |node|
        node.id = node_id
      end
    end

    def nodes
      result = query("MATCH (node) RETURN node")
      result.resultset.map do |item|
        (node_id, labels, properties) = item["node"]
        attrs = {}

        properties.each do |(index, type, value)|
          attrs[get_property(index)] = value
        end
        Node.new(label: get_label(labels.first), properties: attrs).tap do |node|
          node.id = node_id
        end
      end
    end

    # Adds an edge. If successul it returns the created object, otherwise false
    #
    def add_edge(edge)
      result = query("MATCH (src), (dest)
                      WHERE ID(src) = #{edge.src.id} AND ID(dest) = #{edge.dest.id}
                      CREATE (src)-[e:`#{edge.type}` #{quote_hash(edge.properties)}]->(dest) RETURN ID(e)")
      return false if result.stats[:relationships_created] != 1
      id = result.resultset.first["ID(e)"]
      edge.id = id
      edge
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
      out + "}"
    end

    def escape_value(x)
      case x
      when Integer then x
      else
        "'#{x}'"
      end
    end

    def get_label(id)
      @labels ||= labels
      @labels[id] || (@labels = labels)[id]
    end

    def get_property(id)
      @properties ||= properties
      @properties[id] || (@properties = properties)[id]
    end
  end
end
