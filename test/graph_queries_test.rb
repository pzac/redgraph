# frozen_string_literal: true

require "test_helper"

class GraphQueriesTest < Minitest::Test
  include TestHelpers

  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)

    @al = quick_add_node(label: 'actor', properties: {name: "Al Pacino", born: 1940})
    @john = quick_add_node(label: 'actor', properties: {name: "John Travolta", born: 1954})
  end

  def teardown
    @graph.delete
  end

  def test_query_string_attribute
    result = @graph.query("MATCH (n) RETURN n.name ORDER BY n.name")
    assert_equal([["Al Pacino"], ["John Travolta"]], result)
  end

  def test_query_string_and_number_attributes
    result = @graph.query("MATCH (n) RETURN n.name, n.born ORDER BY n.born")
    assert_equal([["Al Pacino", 1940], ["John Travolta", 1954]], result)
  end

  def test_query_nodes
    result = @graph.query("MATCH (n) RETURN n ORDER BY n.born")
    assert_equal([[@al], [@john]], result)
  end

  def test_query_edge
    edge = quick_add_edge(type: 'FRIEND_OF', src: @al, dest: @john, properties: {since: 1980})
    result = @graph.query("MATCH (src)-[edge]->(dest) RETURN edge")
    assert_equal([[edge]], result)
  end

  def test_query_node_and_edge
    edge = quick_add_edge(type: 'FRIEND_OF', src: @al, dest: @john, properties: {since: 1980})
    result = @graph.query("MATCH (src)-[edge:FRIEND_OF]->(dest) RETURN src, edge")
    assert_equal([[@al, edge]], result)
  end

  def test_query_notifications
    payload = nil
    subscription = ActiveSupport::Notifications.subscribe Redgraph::NOTIFICATIONS_KEY do |name, start, finish, id, _payload|
      payload = _payload
    end

    query = "MATCH (n) RETURN n.name ORDER BY n.name"
    result = @graph.query(query)
    assert_includes(payload[:query], query)
  end
end
