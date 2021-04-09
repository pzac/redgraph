# frozen_string_literal: true

module Redgraph
  class Node
    attr_accessor :id, :label, :properties

    def initialize(label:, properties: {})
      @label = label
      @properties = properties
    end

    def persisted?
      !id.nil?
    end
  end
end
