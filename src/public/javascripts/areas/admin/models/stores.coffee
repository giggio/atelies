define [
  'backbone'
  './store'
], (Backbone, Store) ->
  class Products extends Backbone.Collection
    model: Store
    url: "/admin/store"
