module Redgraph
  module NodeModel
    module Persistence
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

      def persisted?
        id.present?
      end

      def reload
        item = self.class.find(id)
        @label = item.label
        assign_attributes(item.attributes)
        self
      end

      # Deletes the record from the graph
      #
      def destroy
        @destroyed = true
        if graph.destroy_node(self)
          self
        else
          false
        end
      end

      # Returns true if this object has been destroyed, otherwise returns false.
      #
      def destroyed?
        !!@destroyed
      end
    end
  end
end
