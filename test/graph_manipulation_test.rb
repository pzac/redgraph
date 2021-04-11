# frozen_string_literal: true

require "test_helper"

class GraphManipulationTest < Minitest::Test
  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)
  end

  def teardown
    @graph.delete
  end

  def test_add_node
    node = Redgraph::Node.new(label: 'actor', properties: {name: "Al Pacino"})
    result = @graph.add_node(node)
    assert_predicate result, :persisted?
  end

  def test_add_node_with_special_chars
    [
      "apo'str",
      "two''apos",
      "Foø'bÆ®",
      "aa\nbb",
      'aaa "bbb" ccc'
    ].each do |name|

      node = Redgraph::Node.new(label: 'actor', properties: {name: name})
      result = @graph.add_node(node)
      assert_predicate result, :persisted?

      item = @graph.find_node_by_id(node.id)

      assert_equal(name, item.properties["name"])
    end
  end

  def test_add_node_with_nil_value
    node = Redgraph::Node.new(label: 'actor', properties: {name: nil})
    result = @graph.add_node(node)
    assert_predicate result, :persisted?

    item = @graph.find_node_by_id(node.id)

    assert_equal("", item.properties["name"])
  end

  def test_add_edge
    actor = Redgraph::Node.new(label: 'actor', properties: {name: "Al Pacino"})
    @graph.add_node(actor)

    film = Redgraph::Node.new(label: 'film', properties: {name: "Scarface"})
    @graph.add_node(film)

    edge = Redgraph::Edge.new(src: actor, dest: film, type: 'ACTOR_IN', properties: {role: "Tony Montana"})
    result = @graph.add_edge(edge)

    assert_predicate result, :persisted?
  end
end
