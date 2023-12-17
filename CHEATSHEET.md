# Cheatsheet

Add node
```
GRAPH.QUERY movies "CREATE(:actor {name: 'Al Pacino'})"
GRAPH.QUERY movies "CREATE(:actor {name: 'John Travolta'})"
```

Query graph
```
GRAPH.QUERY movies "MATCH (n) RETURN n"
GRAPH.QUERY movies "MATCH (n) WHERE ID(n) = 1  RETURN n"
```