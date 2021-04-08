# frozen_string_literal: true

require "test_helper"

class GraphTest < Minitest::Test
  def test_a_bad_connection
    assert_raises(Redis::CannotConnectError) do
      Redgraph::Graph.new("foobar", url: "redis://localhost:80/1")
    end
  end
end
