define [
  'backbone'
], (Backbone) ->
  class User extends Backbone.Model
    idAttribute: "_id"
