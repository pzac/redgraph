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

    # Returns an array of existing relationship types
    #
    def relationship_types
      result = query("CALL db.relationshipTypes()")
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

    # Returns nodes. Options:
    #
    # - label: filter by label
    # - properties: filter by properties
    # - order: node.name ASC, node.year DESC
    # - limit: number of items
    # - skip: items offset (useful for pagination)
    #
    def nodes(label: nil, properties: nil, order: nil, limit: nil, skip: nil)
      _label = ":`#{label}`" if label
      _props = quote_hash(properties) if properties
      _order = if order
        raise MissingAliasPrefixError unless order.include?("node.")
        "ORDER BY #{order}"
      end
      _limit = "LIMIT #{limit}" if limit
      _skip = "SKIP #{skip}" if skip

      cmd = "MATCH (node#{_label} #{_props}) RETURN node #{_order} #{_skip} #{_limit}"

      result = query(cmd)

      result.resultset.map do |item|
        node_from_resultset_item(item["node"])
      end
    end

    # Counts nodes. Options:
    #
    # - label: filter by label
    # - properties: filter by properties
    #
    def count_nodes(label: nil, properties: nil)
      _label = ":`#{label}`" if label
      _props = quote_hash(properties) if properties

      cmd = "MATCH (node#{_label} #{_props}) RETURN COUNT(node)"
      result = query(cmd)

      result.resultset.first["COUNT(node)"]
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

    # Finds edges. Options:
    #
    # - type
    # - src
    # - dest
    # - properties
    # - order
    # - limit
    # - skip
    #
    def edges(type: nil, src: nil, dest: nil, properties: nil, order: nil, limit: nil, skip: nil)
      _type = ":`#{type}`" if type
      _props = quote_hash(properties) if properties
      _order = if order
        raise MissingAliasPrefixError unless order.include?("edge.")
        "ORDER BY #{order}"
      end
      _limit = "LIMIT #{limit}" if limit
      _skip = "SKIP #{skip}" if skip

      _where = if src || dest
        clauses = [
          ("ID(src) = #{src.id}" if src),
          ("ID(dest) = #{dest.id}" if dest)
        ].compact.join(" AND ")
        "WHERE #{clauses}"
      end

      cmd = "MATCH (src)-[edge#{_type} #{_props}]->(dest) #{_where}
             RETURN src, edge, dest #{_order} #{_skip} #{_limit}"
      result = query(cmd)

      result.resultset.map do |item|
        src = node_from_resultset_item(item["src"])
        dest = node_from_resultset_item(item["dest"])
        edge = edge_from_resultset_item(item["edge"])

        edge.src = src
        edge.dest = dest

        edge
      end
    end

    private

    def query(cmd)
      data = @connection.call("GRAPH.QUERY", graph_name, cmd, "--compact")
      QueryResponse.new(data)
    end

    def quote_hash(hash)
      "{" +
      hash.map {|k,v| "#{k}:#{escape_value(v)}" }.join(", ") +
      "}"
    end

    def escape_value(x)
      case x
      when Integer then x
      when NilClass then "''"
      else
        '"' + x.gsub('"', '\"') + '"'
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

    def get_relationship_type(id)
      @relationship_types ||= relationship_types
      @relationship_types[id] || (@relationship_types = relationship_types)[id]
    end

    # Builds a Node object from the raw data
    #
    def node_from_resultset_item(item)
      (node_id, labels, props) = item
      attrs = {}

      props.each do |(index, type, value)|
        attrs[get_property(index)] = value
      end
      Node.new(label: get_label(labels.first), properties: attrs).tap do |node|
        node.id = node_id
      end
    end

    def edge_from_resultset_item(item)
      (edge_id, type_id, _src_id, _dest_id, props) = item
      attrs = {}

      props.each do |(index, type, value)|
        attrs[get_property(index)] = value
      end

      Edge.new.tap do |edge|
        edge.id = edge_id
        edge.type = get_relationship_type(type_id)
        edge.properties = attrs
      end
    end
  end
end
