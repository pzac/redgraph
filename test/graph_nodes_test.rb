# frozen_string_literal: true

require "test_helper"

class GraphNodesTest < Minitest::Test
  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)
  end

  def teardown
    @graph.delete
  end

  def test_add_node
    node = Redgraph::Node.new(label: 'actor', properties: {name: "Al Pacino"})
    result = @graph.add_node(node)

    assert_equal(1, result.stats[:nodes_created])
  end
end
