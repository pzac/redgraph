# frozen_string_literal: true

require "test_helper"

class GraphNodeMethodsTest < Minitest::Test
  def setup
    @graph = Redgraph::Graph.new("movies", url: $REDIS_URL)

    @al = quick_add_node(label: 'actor', properties: {name: "Al Pacino"})
    @john = quick_add_node(label: 'actor', properties: {name: "John Travolta"})
  end

  def teardown
    @graph.delete
  end

  def test_find_node_by_id
    node = @graph.find_node_by_id(@al.id)

    refute_nil(node)
    assert_equal("actor", node.label)
    assert_equal("Al Pacino", node.properties["name"])
    assert_equal(@al.id, node.id)
  end

  def test_find_node_by_wrong_id
    node = @graph.find_node_by_id("-1")

    assert_nil(node)
  end

  def test_find_all_nodes
    actors = @graph.nodes

    assert_equal(2, actors.size)
    assert_includes(actors, @al)
    assert_includes(actors, @john)
  end

  def test_find_all_nodes_by_label
    film = quick_add_node(label: 'film', properties: {name: "Scarface"})

    actors = @graph.nodes(label: 'actor')
    assert_equal(2, actors.size)
    assert_includes(actors, @al)
    assert_includes(actors, @john)

    films = @graph.nodes(label: 'film')
    assert_equal(1, films.size)
    assert_includes(films, film)
  end

  def test_find_all_nodes_by_property
    scarface = quick_add_node(label: 'film', properties: {name: "Scarface", genre: "drama"})
    casino = quick_add_node(label: 'film', properties: {name: "Casino", genre: "drama"})
    _mamma_mia = quick_add_node(label: 'film', properties: {name: "Mamma Mia", genre: "musical"})

    dramas = @graph.nodes(properties: {genre: "drama"})

    assert_equal(2, dramas.size)
    assert_includes(dramas, scarface)
    assert_includes(dramas, casino)
  end

  def test_order_nodes_by_property
    scarface = quick_add_node(label: 'film', properties: {name: "Scarface", genre: "drama"})
    casino = quick_add_node(label: 'film', properties: {name: "Casino", genre: "drama"})
    mamma_mia = quick_add_node(label: 'film', properties: {name: "Mamma Mia", genre: "musical"})

    items = @graph.nodes(label: 'film', order: "node.name")
    assert_equal([casino, mamma_mia, scarface], items)

    items = @graph.nodes(label: 'film', order: "node.name ASC")
    assert_equal([casino, mamma_mia, scarface], items)

    items = @graph.nodes(label: 'film', order: "node.name DESC")
    assert_equal([scarface, mamma_mia, casino], items)
  end

  def test_count_nodes
    quick_add_node(label: 'film', properties: {name: "Scarface", genre: "drama"})
    quick_add_node(label: 'film', properties: {name: "Casino", genre: "drama"})
    quick_add_node(label: 'film', properties: {name: "Mamma Mia", genre: "musical"})


    assert_equal(5, @graph.count_nodes)
    assert_equal(3, @graph.count_nodes(label: 'film'))
    assert_equal(2, @graph.count_nodes(properties: {genre: "drama"}))
  end

  def test_limit_nodes
    10.times do |i|
      quick_add_node(label: 'token', properties: {number: i})
    end

    items = @graph.nodes(label: 'token', limit: 5)
    assert_equal(5, items.size)
    assert_equal([0,1,2,3,4], items.map{|item| item.properties["number"]})
  end

  def test_skip_nodes
    10.times do |i|
      quick_add_node(label: 'token', properties: {number: i})
    end

    items = @graph.nodes(label: 'token', limit: 3, skip: 3)
    assert_equal(3, items.size)
    assert_equal([3,4,5], items.map{|item| item.properties["number"]})
  end

  private

  def quick_add_node(label:, properties:)
    @graph.add_node(Redgraph::Node.new(label: label, properties: properties))
  end
end
