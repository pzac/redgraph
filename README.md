# Redgraph

[![Gem Version](https://badge.fury.io/rb/redgraph.svg)](https://badge.fury.io/rb/redgraph)
[![Code Climate](https://codeclimate.com/github/pzac/redgraph.svg)](https://codeclimate.com/github/pzac/redgraph)

A simple RedisGraph library. This gem owes **a lot** to the existing [redisgraph-rb](https://github.com/RedisGraph/redisgraph-rb) gem, but tries to provide a friendlier interface, similar to the existing [Python](https://github.com/RedisGraph/redisgraph-py) and [Elixir](https://github.com/crflynn/redisgraph-ex) clients.

## July 2023 update:

Sadly RedisGraph is no longer in active development. More info [here](https://redis.com/blog/redisgraph-eol/).

## Nov 2023 update:

There is an active fork, [FalkorDB](https://github.com/FalkorDB/FalkorDB/). AFAIK at this time there are no arm64 builds available.

## Dec 2023 update:

FalkorDB has arm64 builds now.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redgraph'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install redgraph

## Usage

The gem assumes you have a recent version of [RedisGraph](https://oss.redislabs.com/redisgraph/) up and running.

Basic usage:

```ruby
graph = Redgraph::Graph.new('movies', url: "redis://localhost:6379/1")
=> #<Redgraph::Graph:0x00007f8d5c2b7e38 @connection=#<Redis client v4.2.5 for redis://localhost:6379/1>, @graph_name="movies", @module_version=999999>
```

Create a couple nodes:

```ruby
actor = Redgraph::Node.new(label: 'actor', properties: {name: "Al Pacino"})
=> #<Redgraph::Node:0x00007fce3baa0580 @id=nil, @labels=["actor"], @properties={"name"=>"Al Pacino"}>
graph.add_node(actor)
=> #<Redgraph::Node:0x00007fce3baa0580 @id=0, @labels=["actor"], @properties={"name"=>"Al Pacino"}>
film = Redgraph::Node.new(label: 'film', properties: {name: "Scarface"})
=> #<Redgraph::Node:0x00007fce3e8c6c48 @id=nil, @labels=["film"], @properties={"name"=>"Scarface"}>
graph.add_node(film)
=> #<Redgraph::Node:0x00007fce3e8c6c48 @id=1, @labels=["film"], @properties={"name"=>"Scarface"}>
```

Nodes might have multiple labels, although they're not supported by RedisGraph yet (you can track the feature progress [here](https://github.com/RedisGraph/RedisGraph/pull/1561)):

```ruby
item = Redgraph::Node.new(labels: ['film', 'drama'], properties: {name: "Casino"})
=> #<Redgraph::Node:0x00007fce3bc73308 @id=nil, @labels=["film", "drama"], @properties={"name"=>"Casino"}>
```

Create an edge between those nodes:

```ruby
edge = Redgraph::Edge.new(src: actor, dest: film, type: 'ACTOR_IN', properties: {role: "Tony Montana"})
=> #<Redgraph::Edge:0x00007f8d5f9ae3d8 @dest=#<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>, @dest_id=1, @properties={:role=>"Tony Montana"}, @src=#<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>, @src_id=0, @type="ACTOR_IN">
graph.add_edge(edge)
=> #<Redgraph::Edge:0x00007f8d5f9ae3d8 @dest=#<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>, @dest_id=1, @id=0, @properties={:role=>"Tony Montana"}, @src=#<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>, @src_id=0, @type="ACTOR_IN">
```

You can merge nodes - the node will be created only if there isn't another with the same label and properties:

```ruby
graph.merge_node(film)
=> #<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>
```

Same with edges:

```ruby
graph.merge_edge(edge)
=> #<Redgraph::Edge:0x00007f8d5f9ae3d8 @dest=#<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>, @dest_id=1, @id=0, @properties={:role=>"Tony Montana"}, @src=#<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>, @src_id=0, @type="ACTOR_IN">
```

Find a node by id:

```ruby
graph.find_node_by_id(1)
=> #<Redgraph::Node:0x00007f8d5c2c6e88 @id=1, @label="film", @properties={"name"=>"Scarface"}>
```

To get all nodes:

```ruby
graph.nodes
=> [#<Redgraph::Node:0x00007f8d5c2ee0a0 @id=0, @label="actor", @properties={"name"=>"Al Pacino"}>, #<Redgraph::Node:0x00007f8d5c2edfd8 @id=1, @label="film", @properties={"name"=>"Scarface"}>]
```

Optional filters that can be combined:

```ruby
graph.nodes(label: 'actor')
graph.nodes(properties: {name: "Al Pacino"})
graph.nodes(limit: 10, skip: 20)
```

Counting nodes

```ruby
graph.count_nodes(label: 'actor')
=> 1
```

Getting edges:

```ruby
graph.edges
graph.edges(src: actor, dest: film)
graph.edges(kind: 'FRIEND_OF', limit: 10, skip: 20)
graph.count_edges
```

Running custom queries

```ruby
graph.query("MATCH (src)-[edge:FRIEND_OF]->(dest) RETURN src, edge")
```

### NodeModel

You can use the `NodeModel` mixin for a limited ActiveRecord-like interface:

```ruby
class Actor
  include Redgraph::NodeModel
  self.graph = Redgraph::Graph.new("movies", url: $REDIS_URL)
  attribute :name
end
```

And this will give you stuff such as

```ruby
Actor.count
john = Actor.new(name: "John Travolta")
john.add_to_graph
john.add_relation(type: "ACTED_IN", node: film, properties: {role: "Tony Manero"})
john.reload
john.destroy
Actor.create(name: "Al Pacino")
```

`NodeModel` models will automatically set a `_type` property to keep track of the object class.

You will then be able to run custom queries such as:

```ruby
Actor.query("MATCH (node) RETURN node ORDER BY node.name")
```
And the result rows object will be instances of the classes defined by the `_type` attribute.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run 

    TEST_REDIS_URL=YOUR-REDIS-URL rake test

to run the tests. Test coverage will be enabled if you set the `COVERAGE` environment variable to any value.

You can use a `TEST_REDIS_URL` such as `redis://localhost:6379/1`. Make sure you're not overwriting important databases.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Installing RedisGraph

If you're using an Apple silicon mac you might want to use the docker image: I've had issues compiling the module (OpenMP problems). Just do a:

    docker run -p 6380:6379 -it --rm redislabs/redisgraph

or, to try FalkorDB

    docker run -p 6380:6379 -it --rm falkordb/falkordb:edge

and then

    TEST_REDIS_URL=redis://localhost:6380/0 be rake test

I'm using port 6380 to not interphere with the other redis instance.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pzac/redgraph.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
