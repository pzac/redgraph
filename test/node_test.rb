# frozen_string_literal: true

require "test_helper"

class NodeTest < Minitest::Test
  def test_single_labels
    node = Redgraph::Node.new(label: "film")
    assert_equal(["film"], node.labels)
    assert_equal("film", node.label)
  end

  def test_multiple_labels
    node = Redgraph::Node.new(labels: ["film", "drama"])
    assert_equal(["film", "drama"], node.labels)
    assert_equal("film", node.label)
  end

  def test_conflicting_labels
    assert_raises(Redgraph::Error) do
      Redgraph::Node.new(labels: ["film", "drama"], label: "film")
    end
  end
end
