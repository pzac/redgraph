## [0.2.1]

- Add NodeModel#destroy method
- Add NodeModel.create method

## [0.2.0]

- revamp the NodeModel mixin, the Node to model mapping is now handled by the `_type` property

## [0.1.4]

- add NodeModel mixin for a basic ActiveRecord-like syntax
- add Graph#merge_node and Graph#merge_edge 
- edge and node properties are now a HashWithIndifferentAccess

## [0.1.3] - 2021-04-13

- allow custom queries
- nodes and edges query now allow the `order` option

## [0.1.2] - 2021-04-12

- Add Graph#relationship_types
- Add Graph#count_nodes
- Add Graph#edges

## [0.1.1] - 2021-04-11

- Graph#nodes:
    - filter by properties
    - skip and limit options

## [0.1.0] - 2021-04-08

- Initial release
