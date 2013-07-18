define [
  'backboneConfig'
], (Backbone) ->
  class Store extends Backbone.Model
    idAttribute: "_id"
