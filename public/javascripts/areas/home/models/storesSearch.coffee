define [
  'backbone'
  './store'
], (Backbone, Store) ->
  class StoresSearch extends Backbone.Collection
    initialize: (opt) -> @searchTerm = opt?.searchTerm
    model: Store
    url: -> "/stores/search/#{@searchTerm}"
