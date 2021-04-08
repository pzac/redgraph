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

    private

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
  end
end
