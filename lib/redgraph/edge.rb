# frozen_string_literal: true

module Redgraph
  class Edge
    attr_accessor :id, :src, :dest, :type, :properties

    def initialize(src: nil, dest: nil, type: nil, properties: {})
      @src = src
      @dest = dest
      @type = type
      @properties = properties
    end

    def persisted?
      !id.nil?
    end
  end
end
