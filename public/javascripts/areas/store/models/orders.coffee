define [
  'backbone'
  './order'
], (Backbone, Order) ->
  class Orders extends Backbone.Collection
    model: Order
    initialize: (opt) -> @storeId = opt.storeId
    url: -> "/orders/#{@storeId}"
