# frozen_string_literal: true

require "test_helper"

class NodeModelPersistenceTest < Minitest::Test
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

  class Film
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
  end

  # tests
  #

  def test_save_new
    assert_equal(0, Film.count)

    film = Film.new(name: "Star Wars")
    film.save

    assert_predicate(film, :persisted?)
    assert_equal(1, Film.count)
  end

  def test_save_existing
    film = Film.create(name: "Star Wars")
    film.name = "Commando"
    film.save

    assert_equal(1, Film.count)
    item = Film.find(film.id)
    assert_equal("Commando", item.name)
  end

  def test_reload
    film = Film.create(name: "Star Wars")
    copy = Film.find(film.id)

    assert_equal("Star Wars", copy.name)

    film.name = "Commando"
    film.save

    assert_equal("Star Wars", copy.name)
    assert_equal("Commando", copy.reload.name)
  end
end
