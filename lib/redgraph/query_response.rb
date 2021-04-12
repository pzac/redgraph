# frozen_string_literal: true

module Redgraph
  # Wraps the GRAPH.QUERY response, assuming we use the `--compact` output.
  #
  # The response is an array with these objects:
  #
  # - header row
  # - result rows
  # - query stats
  #
  class QueryResponse
    TYPES = [
      UNKNOWN = 0,
      NULL    = 1,
      STRING  = 2,
      INTEGER = 3,
      BOOLEAN = 4,
      DOUBLE  = 5,
      ARRAY   = 6,
      EDGE    = 7,
      NODE    = 8,
      PATH    = 9,
      MAP     = 10,
      POINT   = 11
    ].freeze

    def initialize(response, graph)
      @response = response
      @graph = graph

      @header_row = @response[0]
      @result_rows = @response[1]
      @query_statistics = @response[2]
    end

    def stats
      @stats ||= parse_stats
    end

    def entities
      @entities ||= parse_header
    end

    def resultset
      @resultset ||= parse_resultset
    end

    # Wraps in custom datatypes if needed
    #
    def rows
      @result_rows.map do |column|
        column.map do |data|
          reify_column_item(data)
        end

      end
    end

    private

    def reify_column_item(data)
      value_type, value = data

      case value_type
      when STRING, INTEGER, BOOLEAN, DOUBLE then value
      when NODE then reify_node_item(value)
      when EDGE then reify_edge_item(value)
      else
        "other"
      end
    end

    def reify_node_item(data)
      (node_id, labels, props) = data

      label = @graph.get_label(labels[0]) # Only one label is currently supported

      node = Node.new(label: label)
      node.id = node_id

      props.each do |(prop_id, prop_type, prop_value)|
        prop_name = @graph.get_property(prop_id)
        node.properties[prop_name] = prop_value
      end

      node
    end

    def reify_edge_item(data)
      (edge_id, type_id, src_id, dest_id, props) = data

      type = @graph.get_relationship_type(type_id)

      edge = Edge.new(type: type)
      edge.id = edge_id
      edge.src_id = src_id
      edge.dest_id = dest_id

      props.each do |(prop_id, prop_type, prop_value)|
        prop_name = @graph.get_property(prop_id)
        edge.properties[prop_name] = prop_value
      end

      edge
    end

    # The header lists the entities described in the RETURN clause. It is an
    # array of [ColumnType (enum), name (string)] elements. We can ignore the
    # enum, it is always 1 (COLUMN_SCALAR).
    def parse_header
      @header_row.map{|item| item[1]}
    end

    def parse_stats
      stats = {}

      @query_statistics.each do |item|
        label, value = item.split(":")

        case label
        when /^Nodes created/
          stats[:nodes_created] = value.to_i
        when /^Relationships created/
          stats[:relationships_created] = value.to_i
        when /^Properties set/
          stats[:properties_set] = value.to_i
        when /^Query internal execution time/
          stats[:internal_execution_time] = value
        end
      end

      stats
    end

    # The resultset has one element per entity (as described by the header)
    def parse_resultset
      @result_rows.map do |item|
        out = {}

        item.each.with_index do |(type, value), i|
          out[entities[i]] = value
        end

        out
      end
    end
  end
end
