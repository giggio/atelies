define [
  'backbone'
  './user'
], (Backbone, User) ->
  class Users extends Backbone.Collection
    model: User
    url: "account"
