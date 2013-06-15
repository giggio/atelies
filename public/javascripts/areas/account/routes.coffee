define [
  'jquery'
  '../../viewsManager'
  './views/account'
  './models/users'
  './models/user'
],($, viewsManager, AccountView, Users, User) ->
  class Routes extends Backbone.Open.Routes
    constructor: ->
      viewsManager.$el = $ '#app-container > .account'
    home: ->
      user = accountBootstrapModel.user
      accountView = new AccountView user: user
      viewsManager.show accountView
  new Routes()
