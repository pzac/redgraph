# frozen_string_literal: true

require "test_helper"

class NodeModelTest < Minitest::Test
  include TestHelpers

  GRAPH = Redgraph::Graph.new("movies", url: $REDIS_URL)

  def setup
    @graph = GRAPH
  end

  def teardown
    @graph.delete
  end

  # test classes
  #

  class Animal
    include Redgraph::NodeModel
    attribute :name
    self.graph = "pippo"
  end

  class Dog < Animal
  end

  class Actor
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
  end

  class Film
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
    attribute :year
  end

  # tests
  #

  def test_graph_accessor
    assert_equal("pippo", Animal.graph)
    assert_equal("pippo", Animal.new.graph)
  end

  def test_class_inheritance
    assert_equal("pippo", Dog.graph)
    assert_equal("dog", Dog.label)
    assert_equal([:id, :name], Dog.attribute_names)
  end

  def test_attribute_names
    assert_equal([:id, :name, :year], Film.attribute_names)

    film = Film.new(name: "Star Wars", year: 1977)
    assert_equal("Star Wars", film.name)
    assert_equal(1977, film.year)
  end

  def test_attributes
    film = Film.new(name: "Star Wars", year: 1977)
    assert_equal({id: nil, name: "Star Wars", year: 1977}, film.attributes)
  end

  def test_add_to_graph
    assert_equal(0, Film.count)
    film = Film.new(name: "Star Wars", year: 1977)
    item = film.add_to_graph
    assert_predicate(item, :persisted?)

    assert_equal(1, Film.count)
  end

  def test_merge_into_graph
    film = Film.new(name: "Star Wars", year: 1977)
    item = film.add_to_graph(allow_duplicates: false)
    assert_predicate(item, :persisted?)

    assert_equal(1, Film.count)

    film = Film.new(name: "Star Wars", year: 1977)
    item = film.add_to_graph(allow_duplicates: false)
    assert_predicate(item, :persisted?)

    assert_equal(1, Film.count)
  end

  def test_add_relation
    film = Film.new(name: "Star Wars", year: 1977).add_to_graph
    actor = Actor.new(name: "Harrison Ford").add_to_graph
    edge = actor.add_relation(type: "ACTED_IN", node: film, properties: {role: "Han Solo"})

    assert_predicate(edge, :persisted?)
    assert_equal("ACTED_IN", edge.type)
  end

  def test_add_relation_with_duplicate_control
    film = Film.new(name: "Star Wars", year: 1977).add_to_graph
    actor = Actor.new(name: "Harrison Ford").add_to_graph

    actor.add_relation(type: "ACTED_IN", node: film, properties: {role: "Han Solo"}, allow_duplicates: true)
    assert_equal(1, @graph.count_edges)

    actor.add_relation(type: "ACTED_IN", node: film, properties: {role: "Han Solo"}, allow_duplicates: true)
    assert_equal(2, @graph.count_edges)

    actor.add_relation(type: "ACTED_IN", node: film, properties: {role: "Han Solo"}, allow_duplicates: false)
    assert_equal(2, @graph.count_edges)
  end

  def test_casting_query
    Film.new(name: "Star Wars", year: 1977).add_to_graph
    Actor.new(name: "Harrison Ford").add_to_graph

    items = Film.query("MATCH (node) RETURN node ORDER BY node.name")
    assert_equal(2, items.size)
    assert_kind_of(Actor, items[0][0])
    assert_kind_of(Film, items[1][0])
  end

  def test_casting_query_from_model
    film = Film.create(name: "Star Wars", year: 1977)
    Actor.create(name: "Harrison Ford")

    items = film.query("MATCH (node) RETURN node ORDER BY node.name")
    assert_equal(2, items.size)
    assert_kind_of(Actor, items[0][0])
    assert_kind_of(Film, items[1][0])
  end

end
