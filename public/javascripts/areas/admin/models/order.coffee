define [
  'backboneConfig'
], (Backbone) ->
  class Order extends Backbone.Model
    idAttribute: "_id"
