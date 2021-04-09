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
    def initialize(response)
      @response = response
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

    private

    # The header lists the entities described in the RETURN clause. It is an
    # array of [ColumnType (enum), name (string)] elements. We can ignore the
    # enum, it is always 1 (COLUMN_SCALAR).
    def parse_header
      @response[0].map{|item| item[1]}
    end

    def parse_stats
      stats = {}

      @response[2].each do |item|
        label, value = item.split(":")

        case label
        when /^Nodes created/
          stats[:nodes_created] = value.to_i
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
      @response[1].map do |item|
        out = {}

        item.each.with_index do |(type, value), i|
          out[entities[i]] = value
        end

        out
      end
    end
  end
end
