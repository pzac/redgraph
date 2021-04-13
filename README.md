# Redgraph

A simple RedisGraph library. This gem owes **a lot** to the existing [redisgraph-rb](https://github.com/RedisGraph/redisgraph-rb) gem, but tries to provide a friendlier interface, similar to the existing [Python](https://github.com/RedisGraph/redisgraph-py) and [Elixir](https://github.com/crflynn/redisgraph-ex) clients.

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

    graph = Redgraph::Graph.new('movies', url: "redis://localhost:6379/1")
    => #<Redgraph::Graph:0x00007f8d5c2b7e38 @connection=#<Redis client v4.2.5 for redis://localhost:6379/1>, @graph_name="movies", @module_version=999999>

Create a couple nodes:

    actor = Redgraph::Node.new(label: 'actor', properties: {name: "Al Pacino"})
    => #<Redgraph::Node:0x00007f8d5f95cf88 @label="actor", @properties={:name=>"Al Pacino"}>
    graph.add_node(actor)
    => #<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>
    film = Redgraph::Node.new(label: 'film', properties: {name: "Scarface"})
    => #<Redgraph::Node:0x00007f8d5f85ccc8 @label="film", @properties={:name=>"Scarface"}>
    graph.add_node(film)
    => #<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>

Create an edge between those nodes:

    edge = Redgraph::Edge.new(src: actor, dest: film, type: 'ACTOR_IN', properties: {role: "Tony Montana"})
    => #<Redgraph::Edge:0x00007f8d5f9ae3d8 @dest=#<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>, @dest_id=1, @properties={:role=>"Tony Montana"}, @src=#<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>, @src_id=0, @type="ACTOR_IN">
    @graph.add_edge(edge)
    => #<Redgraph::Edge:0x00007f8d5f9ae3d8 @dest=#<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>, @dest_id=1, @id=0, @properties={:role=>"Tony Montana"}, @src=#<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>, @src_id=0, @type="ACTOR_IN">

You can merge nodes - the node will be created only if there isn't another with the same label and properties:

    graph.merge_node(film)
    => #<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>

Same with edges:

    @graph.merge_edge(edge)
    => #<Redgraph::Edge:0x00007f8d5f9ae3d8 @dest=#<Redgraph::Node:0x00007f8d5f85ccc8 @id=1, @label="film", @properties={:name=>"Scarface"}>, @dest_id=1, @id=0, @properties={:role=>"Tony Montana"}, @src=#<Redgraph::Node:0x00007f8d5f95cf88 @id=0, @label="actor", @properties={:name=>"Al Pacino"}>, @src_id=0, @type="ACTOR_IN">

Find a node by id:

    @graph.find_node_by_id(1)
    => #<Redgraph::Node:0x00007f8d5c2c6e88 @id=1, @label="film", @properties={"name"=>"Scarface"}>

To get all nodes:

    @graph.nodes
    => [#<Redgraph::Node:0x00007f8d5c2ee0a0 @id=0, @label="actor", @properties={"name"=>"Al Pacino"}>, #<Redgraph::Node:0x00007f8d5c2edfd8 @id=1, @label="film", @properties={"name"=>"Scarface"}>]

Optional filters that can be combined:

    @graph.nodes(label: 'actor')
    @graph.nodes(properties: {name: "Al Pacino"})
    @graph.nodes(limit: 10, skip: 20)

Counting nodes

    @graph.count_nodes(label: 'actor')
    => 1

Getting edges:

    @graph.edges
    @graph.edges(src: actor, dest: film)
    @graph.edges(kind: 'FRIEND_OF', limit: 10, skip: 20)

Running custom queries

    @graph.query("MATCH (src)-[edge:FRIEND_OF]->(dest) RETURN src, edge")


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run 

    TEST_REDIS_URL=YOUR-REDIS-URL rake test

to run the tests. Test coverage will be enabled if you set the `COVERAGE` environment variable to any value.

You can use a `TEST_REDIS_URL` such as `redis://localhost:6379/1`. Make sure you're not overwriting important databases.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pzac/redgraph.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
