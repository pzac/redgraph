# frozen_string_literal: true

module Redgraph
  class Graph
    module EdgeMethods
      # Adds an edge. If successul it returns the created object, otherwise false
      #
      def add_edge(edge)
        result = _query("MATCH (src), (dest)
                        WHERE ID(src) = #{edge.src.id} AND ID(dest) = #{edge.dest.id}
                        CREATE (src)-[e:`#{edge.type}` #{quote_hash(edge.properties)}]->(dest) RETURN ID(e)")
        return false if result.stats[:relationships_created] != 1
        id = result.resultset.first["ID(e)"]
        edge.id = id
        edge
      end

      # Finds edges. Options:
      #
      # - type
      # - src
      # - dest
      # - properties
      # - order
      # - limit
      # - skip
      #
      def edges(type: nil, src: nil, dest: nil, properties: nil, order: nil, limit: nil, skip: nil)
        _type = ":`#{type}`" if type
        _props = quote_hash(properties) if properties
        _order = if order
          raise MissingAliasPrefixError unless order.include?("edge.")
          "ORDER BY #{order}"
        end
        _limit = "LIMIT #{limit}" if limit
        _skip = "SKIP #{skip}" if skip

        _where = if src || dest
          clauses = [
            ("ID(src) = #{src.id}" if src),
            ("ID(dest) = #{dest.id}" if dest)
          ].compact.join(" AND ")
          "WHERE #{clauses}"
        end

        cmd = "MATCH (src)-[edge#{_type} #{_props}]->(dest) #{_where}
               RETURN src, edge, dest #{_order} #{_skip} #{_limit}"
        result = _query(cmd)

        result.resultset.map do |item|
          src = node_from_resultset_item(item["src"])
          dest = node_from_resultset_item(item["dest"])
          edge = edge_from_resultset_item(item["edge"])

          edge.src = src
          edge.dest = dest

          edge
        end
      end

      private

      def edge_from_resultset_item(item)
        (edge_id, type_id, _src_id, _dest_id, props) = item
        attrs = {}

        props.each do |(index, type, value)|
          attrs[get_property(index)] = value
        end

        Edge.new.tap do |edge|
          edge.id = edge_id
          edge.type = get_relationship_type(type_id)
          edge.properties = attrs
        end
      end
    end
  end
end
