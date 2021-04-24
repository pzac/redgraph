# frozen_string_literal: true

module Redgraph
  class Node
    include Util

    attr_accessor :id, :labels, :properties

    def initialize(label: nil, properties: nil, id: nil, labels: nil)
      @id = id
      raise(Error, "You can either define a single label or a label array") if label && labels
      @labels = labels || (label ? [label] : [])
      @properties = (properties || {}).with_indifferent_access
    end

    def label
      labels.first
    end

    def persisted?
      id.present?
    end

    def ==(other)
      super || other.instance_of?(self.class) && !id.nil? && other.id == id
    end

    def to_query_string(item_alias: 'node')
      _label = labels.map {|l| ":`#{l}`"}.join
      "(#{item_alias}#{_label} #{properties_to_string(properties)})"
    end
  end
end
