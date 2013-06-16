define [
  'jquery'
  '../../viewsManager'
  './views/account'
  './views/orders'
  './models/users'
  './models/user'
],($, viewsManager, AccountView, OrdersView, Users, User) ->
  class Routes extends Backbone.Open.Routes
    constructor: ->
      viewsManager.$el = $ '#app-container > .account'
    home: ->
      user = accountBootstrapModel.user
      accountView = new AccountView user: user
      viewsManager.show accountView
    orders: ->
      user = accountBootstrapModel.user
      orders = accountBootstrapModel.orders
      ordersView = new OrdersView user: user, orders: orders
      viewsManager.show ordersView

  new Routes()
