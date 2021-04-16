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

  class Actor
    include Redgraph::NodeModel
    self.graph = GRAPH
    attribute :name
  end

  def test_label
    assert_equal("actor", Actor.label)
  end

  def test_default_label_registration
    assert_equal("Actor", Redgraph::NodeModel::Registry.class_name_for_label("actor"))
  end

  class Artist
    include Redgraph::NodeModel
    self.label = "_artist"
  end

  def test_custom_label
    assert_equal("_artist", Artist.label)
  end

  def test_custom_label_registration
    assert_equal("Artist", Redgraph::NodeModel::Registry.class_name_for_label("_artist"))
  end

  class Painter < Artist
  end

  def test_default_label_when_inherited
    assert_equal("painter", Painter.label)
    assert_equal("Painter", Redgraph::NodeModel::Registry.class_name_for_label("painter"))
  end

  class Pianist < Artist
    self.label = "pianist"
  end

  def test_custom_label_when_inherited
    assert_equal("pianist", Pianist.label)
    assert_equal("Pianist", Redgraph::NodeModel::Registry.class_name_for_label("pianist"))
  end
end
