define [
  'backboneConfig'
  './store'
], (Backbone, Store) ->
  class Products extends Backbone.Collection
    model: Store
    url: "/api/admin/store"
