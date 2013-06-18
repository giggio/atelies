define [
  'backbone'
  './order'
], (Backbone, Order) ->
  class Orders extends Backbone.Collection
    initialize: (models, opt) ->
      @_id = opt._id
    model: Order
    url: -> "account/orders/#{@_id}"
