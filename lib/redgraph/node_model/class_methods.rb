module Redgraph
  module NodeModel
    module ClassMethods
      # Returns an array of nodes. Options:
      #
      # - properties: filter by properties
      # - order: node.name ASC, node.year DESC
      # - limit: number of items
      # - skip: items offset (useful for pagination)
      #
      def all(properties: nil, limit: nil, skip: nil, order: nil)
        graph.nodes(label: label, properties: properties,
                    limit: limit, skip: skip, order: nil).map do |node|
          reify_from_node(node)
        end
      end

      # Returns the number of nodes with the current label. Options:
      #
      # - properties: filter by properties
      #
      def count(properties: nil)
        graph.count_nodes(label: label, properties: properties)
      end

      # Finds a node by id. Returns nil if not found
      #
      def find(id)
        node = graph.find_node_by_id(id)
        return unless node
        reify_from_node(node)
      end

      # Sets the label for this class of nodes. If missing it will be computed from the class name
      def label=(x)
        @label = x
      end

      # Current label
      #
      def label
        @label ||= default_label
      end

      # Converts a Node object into NodeModel
      #
      def reify_from_node(node)
        new(id: node.id, **node.properties)
      end

      private

      def default_label
        name.demodulize.underscore
      end
    end
  end
end
