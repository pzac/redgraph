# frozen_string_literal: true

require "test_helper"

class GraphQueriesTest < Minitest::Test
  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)

    @al = quick_add_node(label: 'actor', properties: {name: "Al Pacino"})
    @john = quick_add_node(label: 'actor', properties: {name: "John Travolta"})
  end

  def teardown
    @graph.delete
  end

  private

  def quick_add_node(label:, properties:)
    @graph.add_node(Redgraph::Node.new(label: label, properties: properties))
  end

  def quick_add_edge(type:, src:, dest:, properties:)
    @graph.add_edge(Redgraph::Edge.new(type: type, src: src, dest: dest, properties: properties))
  end
end
