module Redgraph
  module NodeModel
    module GraphManipulation
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

      # Runs a custom query on the graph
      #
      def query(cmd)
        self.class.query(cmd)
      end
    end
  end
end
