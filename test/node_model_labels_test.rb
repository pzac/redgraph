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

  class Artist
    include Redgraph::NodeModel
    self.label = "person"
  end

  def test_custom_label
    assert_equal("person", Artist.label)
  end
end
