# frozen_string_literal: true

require "test_helper"

class NodeModelLabelsTest < Minitest::Test
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

  class Artist
    include Redgraph::NodeModel
    self.label = "_artist"
  end

  class Painter < Artist
  end

  class Pianist < Artist
    self.label = "pianist"
  end

  # tests
  #

  def test_label
    assert_equal("actor", Actor.label)
  end

  def test_custom_label
    assert_equal("_artist", Artist.label)
  end

  def test_default_label_when_inherited
    assert_equal("painter", Painter.label)
  end

  def test_custom_label_when_inherited
    assert_equal("pianist", Pianist.label)
  end
end
