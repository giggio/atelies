define [
  'jquery'
  '../../viewsManager'
  './views/account'
  './views/orders'
  './views/order'
  './views/userNotVerified'
  './models/orders'
],($, viewsManager, AccountView, OrdersView, OrderView, UserNotVerifiedView, Orders) ->
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
    order: (_id) ->
      user = accountBootstrapModel.user
      order = _.findWhere accountBootstrapModel.orders, _id: _id
      orders = new Orders [order], _id: _id
      orders.fetch
        success: (col, res, opt) ->
          order = orders.at(0).toJSON()
          orderView = new OrderView user: user, order: order
          viewsManager.show orderView
        error: (col, res, opt) ->
          console.log 'error loading orders'
    userNotVerified: ->
      user = accountBootstrapModel.user
      userNotVerifiedView = new UserNotVerifiedView user: user
      viewsManager.show userNotVerifiedView

  new Routes()
