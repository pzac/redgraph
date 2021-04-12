module Redgraph
  class Graph
    module NodeMethods
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

      private

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
    end
  end
end
