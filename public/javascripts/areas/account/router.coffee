define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  './views/account'
  './views/orders'
  './views/order'
  './views/userNotVerified'
  './models/orders'
  '../shared/views/dialog'
],($, _, Backbone, viewsManager, AccountView, OrdersView, OrderView, UserNotVerifiedView, Orders, Dialog) ->
  class Router extends Backbone.Open.Router
    area: 'account'
    logCategory: 'account'
    constructor: ->
      viewsManager.$el = $ '#app-container > .account'
      @_createRoutes
        '': @home
        'orders': @orders
        'orders/:orderId': @order
        'userNotVerified': @userNotVerified
      _.bindAll @
      super
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
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível carregar o pedido. Tente novamente mais tarde."
          Backbone.history.navigate "orders"
    userNotVerified: ->
      user = accountBootstrapModel.user
      userNotVerifiedView = new UserNotVerifiedView user: user
      viewsManager.show userNotVerifiedView
