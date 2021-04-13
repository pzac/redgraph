# frozen_string_literal: true

require "test_helper"

class GraphEdgeMethodsTest < Minitest::Test
  include TestHelpers

  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)

    @al = quick_add_node(label: 'actor', properties: {name: "Al Pacino"})
    @john = quick_add_node(label: 'actor', properties: {name: "John Travolta"})
  end

  def teardown
    @graph.delete
  end

  def test_find_edge
    quick_add_edge(type: 'FRIEND_OF', src: @al, dest: @john, properties: {since: 1980})
    edge = @graph.edges.first

    assert_equal('FRIEND_OF', edge.type)
    assert_equal(1980, edge.properties["since"])
    assert_equal(@al, edge.src)
    assert_equal(@john, edge.dest)

  end

  def test_find_all_edges
    marlon = quick_add_node(label: 'actor', properties: {name: "Marlon Brando"})
    film = quick_add_node(label: 'film', properties: {name: "The Godfather"})
    quick_add_edge(type: 'ACTOR_IN', src: marlon, dest: film, properties: {role: 'Don Vito'})
    quick_add_edge(type: 'ACTOR_IN', src: @al,    dest: film, properties: {role: 'Michael'})

    edges = @graph.edges
    assert_equal(2, edges.size)
  end

  def test_filter_edges
    marlon = quick_add_node(label: 'actor', properties: {name: "Marlon Brando"})
    film = quick_add_node(label: 'film', properties: {name: "The Godfather"})
    other_film = quick_add_node(label: 'film', properties: {name: "Carlito's Way"})
    e_donvito = quick_add_edge(type: 'ACTOR_IN', src: marlon, dest: film, properties: {role: 'Don Vito'})
    e_michael = quick_add_edge(type: 'ACTOR_IN', src: @al, dest: film, properties: {role: 'Michael'})
    e_carlito = quick_add_edge(type: 'ACTOR_IN', src: @al, dest: other_film, properties: {role: 'Carlito'})
    quick_add_edge(type: 'FRIEND_OF', src: @al, dest: marlon, properties: {since: 1980})

    edges = @graph.edges(type: "FRIEND_OF")
    assert_equal(1, edges.size)

    edges = @graph.edges(type: "ACTOR_IN")
    assert_equal(3, edges.size)

    edges = @graph.edges(type: "ACTOR_IN", limit: 2)
    assert_equal(2, edges.size)

    edges = @graph.edges(type: "ACTOR_IN", skip: 2, limit: 10)
    assert_equal(1, edges.size)

    edges = @graph.edges(properties: {role: "Carlito"})
    assert_equal([e_carlito], edges)

    edges = @graph.edges(src: marlon)
    assert_equal([e_donvito], edges)

    edges = @graph.edges(type: 'ACTOR_IN', dest: film)
    assert_equal(2, edges.size)
    assert_includes(edges, e_donvito)
    assert_includes(edges, e_michael)

    edges = @graph.edges(src: @al, dest: marlon)
    assert_equal(1, edges.size)
    edge = edges[0]
    assert_equal('FRIEND_OF', edge.type)
    assert_equal(1980, edge.properties["since"])
  end

  def test_order_edges
    marlon = quick_add_node(label: 'actor', properties: {name: "Marlon Brando"})

    e1 = quick_add_edge(type: 'FRIEND_OF', src: @al, dest: marlon, properties: {since: 1980})
    e2 = quick_add_edge(type: 'FRIEND_OF', src: @al, dest: @john, properties: {since: 2000})
    e3 = quick_add_edge(type: 'FRIEND_OF', src: marlon, dest: @john, properties: {since: 1990})

    edges = @graph.edges(type: 'FRIEND_OF', order: "edge.since ASC")
    assert_equal([e1, e3, e2], edges)

    edges = @graph.edges(type: 'FRIEND_OF', order: "edge.since DESC")
    assert_equal([e2, e3, e1], edges)
  end
end
