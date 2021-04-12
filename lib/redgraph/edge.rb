# frozen_string_literal: true

module Redgraph
  class Edge
    attr_accessor :id, :src, :dest, :src_id, :dest_id, :type, :properties

    def initialize(src: nil, dest: nil, type: nil, properties: {})
      @src = src
      @src_id = @src.id if @src
      @dest = dest
      @dest_id = @dest.id if @dest
      @type = type
      @properties = properties
    end

    def persisted?
      !id.nil?
    end

    def ==(other)
      super || other.instance_of?(self.class) && !id.nil? && other.id == id
    end
  end
end
