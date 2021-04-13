# frozen_string_literal: true

module Redgraph
  class Node
    attr_accessor :id, :label, :properties

    def initialize(label:, properties: {})
      @label = label
      @properties = properties.with_indifferent_access
    end

    def persisted?
      id.present?
    end

    def ==(other)
      super || other.instance_of?(self.class) && !id.nil? && other.id == id
    end
  end
end
