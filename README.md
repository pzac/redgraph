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

Create a couple nodes:

    actor = Redgraph::Node.new(label: 'actor', attributes: {name: "Al Pacino"})
    graph.add_node(actor)
    film = Redgraph::Node.new(label: 'film', attributes: {name: "Scarface"})
    graph.add_node(film)

Create an edge between those nodes:

    edge = Redgraph::Edge.new(src: actor, dest: film, type: 'ACTOR_IN', properties: {role: "Tony Montana"})
    result = @graph.add_edge(edge)

Find a node by id:

    @graph.find_node_by_id(123)

To get all nodes:

    @graph.nodes

Optional filters that can be combined:

    @graph.nodes(label: 'actor')
    @graph.nodes(properties: {name: "Al Pacino"})
    @graph.nodes(limit: 10, skip: 20)

Counting nodes

    @graph.count_nodes(label: 'actor')

Getting edges:

    @graph.edges
    @graph.edges(src: actor, dest: film)
    @graph.edges(kind: 'FRIEND_OF', limit: 10, skip: 20)

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
