module Redgraph
  module NodeModel
    module ClassMethods
      # Returns an array of nodes. Options:
      #
      # - label: filter by label
      # - properties: filter by properties
      # - order: node.name ASC, node.year DESC
      # - limit: number of items
      # - skip: items offset (useful for pagination)
      #
      def all(label: nil, properties: {}, limit: nil, skip: nil, order: nil)
        graph.nodes(label: label, properties: properties_plus_type(properties),
                    limit: limit, skip: skip, order: nil).map do |node|
          reify_from_node(node)
        end
      end

      # Returns the number of nodes with the current label. Options:
      #
      # - properties: filter by properties
      #
      def count(label: nil, properties: nil)
        graph.count_nodes(label: label, properties: properties_plus_type(properties))
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
        klass = node.properties[:_type].to_s.safe_constantize || self
        klass.new(id: node.id, **node.properties)
      end

      # Runs a query on the graph, but converts the nodes to the corresponding ActiveModel class
      # if available - otherwise they stay NodeObjects.
      #
      # Returns an array of rows.
      #
      def query(cmd)
        raise MissingGraphError unless graph

        graph.query(cmd).map do |row|
          row.map do |item|
            item.is_a?(Node) ? reify_from_node(item) : item
          end
        end
      end

      def create(properties)
        new(**properties).add_to_graph
      end

      private

      def default_label
        name.demodulize.underscore
      end

      def properties_plus_type(properties = {})
        {_type: name}.merge(properties || {})
      end
    end
  end
end
