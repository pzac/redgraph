# frozen_string_literal: true

module Redgraph
  class Node
    attr_accessor :label, :properties

    def initialize(label:, properties: {})
      @label = label
      @properties = properties
    end
  end
end
