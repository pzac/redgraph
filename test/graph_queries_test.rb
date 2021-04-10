# frozen_string_literal: true

require "test_helper"

class GraphQueriesTest < Minitest::Test
  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)
    @actor = Redgraph::Node.new(label: 'actor', properties: {name: "Al Pacino"})
    result = @graph.add_node(@actor)

    refute_nil(@actor.id)
  end

  def teardown
    @graph.delete
  end

  def test_find_node_by_id
    node = @graph.find_node_by_id(@actor.id)

    refute_nil(node)
    assert_equal("actor", node.label)
    assert_equal("Al Pacino", node.properties["name"])
    assert_equal(@actor.id, node.id)
  end

  def test_find_node_by_wrong_id
    node = @graph.find_node_by_id("-1")

    assert_nil(node)
  end
end
