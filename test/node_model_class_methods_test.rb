# frozen_string_literal: true

require "test_helper"

class NodeModelClassMethodsTest < Minitest::Test
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

  class Actor
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
  end

  class MissingGraphActor
    include Redgraph::NodeModel
    attribute :name
  end

  # tests
  #

  def test_count
    quick_add_node(label: 'actor', properties: {_type: Actor.name, name: "Al Pacino"})
    quick_add_node(label: 'actor', properties: {_type: Actor.name, name: "John Travolta"})
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
    item = Actor.find(999999)
    assert_nil(item)
  end

  def test_create
    assert_equal(0, Actor.count)

    actor = Actor.create(name: "Harrison Ford")

    assert_equal(1, Actor.count)
    assert_predicate(actor, :persisted?)
    assert_equal("Harrison Ford", actor.name)
    assert_equal("actor", actor.label)

    found = Actor.find(actor.id)
    assert_equal("Harrison Ford", found.name)
    assert_equal("actor", found.label)
    assert_equal(Actor.name, found._type)
  end

  def test_create_with_missing_graph
    assert_raises(Redgraph::MissingGraphError) do
      MissingGraphActor.create(name: "Harrison Ford")
    end
  end
end
