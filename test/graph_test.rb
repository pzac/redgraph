# frozen_string_literal: true

require "test_helper"

class GraphTest < Minitest::Test
  def setup
    @graph = create_sample_graph("foobar")
  end

  def teardown
    @graph.delete
  end

  def test_list
    list = @graph.list
    assert_includes(list, "foobar")
  end

  def test_delete
    assert_includes(@graph.list, "foobar")

    @graph.delete
    refute_includes(@graph.list, "foobar")
  end

  def test_labels
    @graph = create_sample_graph("foobar")
    assert_equal(["actor"], @graph.labels)

    node = Redgraph::Node.new(label: "film")
    @graph.add_node(node)
    assert_equal(["actor", "film"], @graph.labels)
  end

  def test_properties
    @graph = create_sample_graph("foobar")
    assert_equal(["name"], @graph.properties)

    node = Redgraph::Node.new(label: "actor", properties: {"age": 100})
    @graph.add_node(node)

    assert_equal(["name", "age"], @graph.properties)
  end

  private

  def create_sample_graph(name)
    graph = Redgraph::Graph.new(name, url: $REDIS_URL)
    graph.connection.call(
      "GRAPH.QUERY",
      name,
      "CREATE (:actor {name: 'hello'})"
    )
    graph
  end
end
