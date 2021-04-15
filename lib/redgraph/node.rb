# frozen_string_literal: true

module Redgraph
  class Node
    include Util

    attr_accessor :id, :label, :properties

    def initialize(label: nil, properties: nil, id: nil)
      @id = id
      @label = label
      @properties = (properties || {}).with_indifferent_access
    end

    def persisted?
      id.present?
    end

    def ==(other)
      super || other.instance_of?(self.class) && !id.nil? && other.id == id
    end

    def to_query_string(item_alias: 'node')
      _label = ":#{label}" if label
      "(#{item_alias}#{_label} #{properties_to_string(properties)})"
    end
  end
end
