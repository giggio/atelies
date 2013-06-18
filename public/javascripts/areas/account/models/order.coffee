define [
  'backbone'
], (Backbone) ->
  class Order extends Backbone.Model
    idAttribute: "_id"
