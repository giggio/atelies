define [
  'backboneConfig'
  './order'
], (Backbone, Order) ->
  class Orders extends Backbone.Collection
    model: Order
    initialize: (opt) -> @storeId = opt.storeId
    url: -> "/api/orders/#{@storeId}"
