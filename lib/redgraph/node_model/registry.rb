module Redgraph
  module NodeModel
    # The purpose of this module is to store the NodeModel-Node mappings
    module Registry
      def self.mappings
        @mappings ||= {}.with_indifferent_access
      end

      def self.register_node_model(item)
        mappings[item.label] = item.to_s.demodulize
      end

      def self.class_name_for_label(label)
        mappings[label]
      end

      def self.class_for_label(label)
        class_name_for_label(label).safe_constantize
      end

      def self.clear_mappings
        @mappings = {}.with_indifferent_access
      end
    end
  end
end
