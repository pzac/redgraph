# frozen_string_literal: true

module Redgraph
  class Graph
    module NodeMethods
      # Adds a node. If successul it returns the created object, otherwise false
      #
      def add_node(node)
        merge_or_add_node(node, :create)
      end

      # Merges (creates a node unless one with the same label and properties exists). If successul
      # it returns the object, otherwise false
      #
      def merge_node(node)
        merge_or_add_node(node, :merge)
      end

      def find_node_by_id(id)
        result = _query("MATCH (node) WHERE ID(node) = #{id} RETURN node")
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
        _order = if order
          raise MissingAliasPrefixError unless order.include?("node.")
          "ORDER BY #{order}"
        end
        _limit = "LIMIT #{limit}" if limit
        _skip = "SKIP #{skip}" if skip

        node = Node.new(label: label, properties: properties)

        cmd = "MATCH #{node.to_query_string} RETURN node #{_order} #{_skip} #{_limit}"

        result = _query(cmd)

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
        node = Node.new(label: label, properties: properties)

        cmd = "MATCH #{node.to_query_string} RETURN COUNT(node)"
        # RedisGraph bug: if there are no matches COUNT returns zero rows
        # https://github.com/RedisGraph/RedisGraph/issues/1455
        query(cmd).flatten[0] || 0
      end

      private

      # Builds a Node object from the raw data
      #
      def node_from_resultset_item(item)
        (node_id, labels, props) = item
        attrs = HashWithIndifferentAccess.new

        props.each do |(index, type, value)|
          attrs[get_property(index)] = value
        end
        Node.new(label: get_label(labels.first), properties: attrs).tap do |node|
          node.id = node_id
        end
      end

      def merge_or_add_node(node, verb = :create)
        verb = verb == :create ? "CREATE" : "MERGE"
        result = _query("#{verb} #{node.to_query_string} RETURN ID(node)")
        # Should we treat this case differently?
        # return false if result.stats[:nodes_created] != 1
        id = result.resultset.first["ID(node)"]
        node.id = id
        node
      end

    end
  end
end
