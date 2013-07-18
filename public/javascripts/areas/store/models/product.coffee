define [
  'backboneConfig'
], (Backbone) ->
  class Product extends Backbone.Model
    idAttribute: "_id"
