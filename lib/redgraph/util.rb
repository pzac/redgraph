# frozen_string_literal: true

module Redgraph
  module Util
    def properties_to_string(hash)
      return if hash.empty?
      "{" +
      hash.map {|k,v| "#{k}:#{escape_value(v)}" }.join(", ") +
      "}"
    end

    def escape_value(x)
      case x
      when Integer then x
      when NilClass then "''"
      else
        '"' + x.gsub('"', '\"') + '"'
      end
    end
  end
end
