# frozen_string_literal: true

require "test_helper"

class GraphTest < Minitest::Test
  def test_a_bad_connection
    assert_raises(Redis::CannotConnectError) do
      Redgraph::Graph.new("foobar", url: "redis://localhost:80/1")
    end
  end

  def test_list
    @graph = create_sample_graph("foobar")
    list = @graph.list
    assert_includes(list, "foobar")
  end

  def test_delete
    @graph = create_sample_graph("foobar")
    assert_includes(@graph.list, "foobar")

    @graph.delete
    refute_includes(@graph.list, "foobar")
  end

  private

  def create_sample_graph(name)
    graph = Redgraph::Graph.new(name)
    graph.connection.call(
      "GRAPH.QUERY",
      name,
      "CREATE (:node {name: 'hello'})"
    )
    graph
  end
end
