define [
  'backboneConfig'
  './productHome'
], (Backbone, Store) ->
  class ProductsSearch extends Backbone.Collection
    initialize: (opt) -> @searchTerm = opt?.searchTerm
    model: Store
    url: -> "/api/products/search/#{@searchTerm}"
