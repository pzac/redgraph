# frozen_string_literal: true

module Redgraph
  # This mixin allows you to use an interface similar to ActiveRecord
  #
  # class Actor
  #   include Redgraph::NodeModel
  #
  #   self.graph = Redgraph::Graph.new("movies", url: $REDIS_URL)
  #   self.label = "actor" # optional, if missing it will be extracted from the class name
  #   attribute :name
  # end
  #
  # You will then be able to
  #
  # john = Actor.find(123)
  # total = Actor.count
  #
  module NodeModel
    extend ActiveSupport::Concern

    included do
      @attribute_names = [:id]

      attr_accessor :id

      class << self
        attr_reader :attribute_names
        attr_accessor :graph

        def attribute(name)
          @attribute_names << name
          attr_reader(name)
        end

        private

        def inherited(subclass)
          super
          subclass.instance_variable_set(:@attribute_names, @attribute_names.dup)
          subclass.instance_variable_set(:@graph, @graph.dup)
        end
      end
    end

    class_methods do
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
          new(id: node.id, **node.properties)
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
        new(id: node.id, **node.properties)
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

      private

      def default_label
        name.demodulize.underscore
      end
    end

    def initialize(**args)
      absent_attributes = args.keys.map(&:to_sym) - self.class.attribute_names

      if absent_attributes.any?
        raise ArgumentError, "Unknown attribute #{absent_attributes}"
      end

      args.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end

    # The current graph
    #
    def graph
      self.class.graph
    end

    def label
      self.class.label
    end

    # Object attributes as a hash
    #
    def attributes
      self.class.attribute_names.to_h { |name| [name, public_send(name)] }
    end

    def persisted?
      id.present?
    end

    # Adds the node to the graph
    #
    # - allow_duplicates: if false it will create a node with the same type and properties only if
    #     not present
    #
    def add_to_graph(allow_duplicates: true)
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

    def to_node
      Redgraph::Node.new(id: id, label: label, properties: attributes.except(:id))
    end

    def ==(other)
      attributes == other.attributes && id == other.id
    end

  end
end
