module Redgraph
  module NodeModel
    module GraphManipulation
      # Adds the node to the graph
      #
      # - allow_duplicates: if false it will create a node with the same type and properties only if
      #     not present
      #
      def add_to_graph(allow_duplicates: true)
        raise MissingGraphError unless graph
        item = allow_duplicates ? graph.add_node(to_node) : graph.merge_node(to_node)
        self.id = item.id
        self
      end

      # Adds a relation between the node and another node.
      #
      # - type: type of relation
      # - node: the destination node
      # - properties: optional properties hash
      # - allow_duplicates: if false it will create a relation between two nodes with the same type
      #     and properties only if not present
      #
      def add_relation(type:, node:, properties: nil, allow_duplicates: true)
        edge = Edge.new(type: type, src: to_node, dest: node.to_node, properties: properties)
        allow_duplicates ? graph.add_edge(edge) : graph.merge_edge(edge)
      end

      # Creates a new record or updates the existing
      #
      def save
        if persisted?
          item = graph.update_node(to_node)
          self.class.reify_from_node(item)
        else
          add_to_graph
        end
      end

      # Runs a custom query on the graph
      #
      def query(cmd)
        self.class.query(cmd)
      end
    end
  end
end
