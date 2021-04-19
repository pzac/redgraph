# frozen_string_literal: true
require_relative 'node_model/class_methods'
require_relative 'node_model/graph_manipulation'

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
  # When you create a record it will automatically set the _type property with the class name.
  # This allows reifying the node into the corresponding NodeModel class.
  #
  module NodeModel
    extend ActiveSupport::Concern

    included do |base|
      include GraphManipulation
      @attribute_names = [:id]

      attr_accessor :id, :_type

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

    def initialize(**args)
      absent_attributes = args.keys.map(&:to_sym) - self.class.attribute_names - [:_type]

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

    def to_node
      props = attributes.except(:id).merge(_type: self.class.name)
      Redgraph::Node.new(id: id, label: label, properties: props)
    end

    def ==(other)
      attributes == other.attributes && id == other.id
    end

  end
end
