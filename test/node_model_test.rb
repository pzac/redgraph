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

  class Animal
    include Redgraph::NodeModel
    attribute :name
    self.graph = "pippo"
  end

  class Dog < Animal
  end

  def test_graph_accessor
    assert_equal("pippo", Animal.graph)
    assert_equal("pippo", Animal.new.graph)
  end

  def test_class_inheritance
    assert_equal("pippo", Dog.graph)
    assert_equal("dog", Dog.label)
    assert_equal([:id, :name], Dog.attribute_names)
  end

  class Actor
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
  end

  def test_count
    quick_add_node(label: 'actor', properties: {name: "Al Pacino"})
    quick_add_node(label: 'actor', properties: {name: "John Travolta"})
    assert_equal(2, Actor.count)
    assert_equal(1, Actor.count(properties: {name: "Al Pacino"}))
  end

  def test_all
    al = Actor.new(name: "Al Pacino").add_to_graph
    john = Actor.new(name: "John Travolta").add_to_graph

    items = Actor.all
    assert_equal(2, items.size)
    assert_includes(items, al)
    assert_includes(items, john)

    items = Actor.all(properties: {name: "Al Pacino"})
    assert_equal(1, items.size)
    assert_includes(items, al)
  end

  def test_find
    al = quick_add_node(label: 'actor', properties: {name: "Al Pacino"})
    item = Actor.find(al.id)

    assert_equal(Actor, item.class)
    assert_predicate(item, :persisted?)
    assert_equal(al.id, item.id)
    assert_equal("Al Pacino", item.name)
  end

  def test_find_bad_id
    quick_add_node(label: 'actor', properties: {name: "Al Pacino"})
    item = Actor.find("-1")
    assert_nil(item)
  end

  def test_label
    assert_equal("actor", Actor.label)
  end

  class Artist
    include Redgraph::NodeModel
    self.label = "person"
  end

  def test_custom_label
    assert_equal("person", Artist.label)
  end

  class Film
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
    attribute :year
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

end
