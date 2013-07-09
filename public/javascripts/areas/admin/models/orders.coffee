define [
  'backbone'
  './order'
], (Backbone, Order) ->
  class Orders extends Backbone.Collection
    model: Order
    url: "admin/orders"
