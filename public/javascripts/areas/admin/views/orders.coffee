define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/orderStatus'
  'text!./templates/orders.html'
  '../../../converters'
], ($, _, Backbone, Handlebars, OrderStatus, ordersTemplate, converters) ->
  class OrdersView extends Backbone.Open.View
    template: ordersTemplate
    initialize: (opt) ->
      @orders = opt.orders
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      orders = _.map @orders, (o) ->
        _id: o._id
        storeName: o.storeName
        storeSlug: o.storeSlug
        totalSaleAmount: converters.currency o.totalSaleAmount
        orderDate: converters.prettyDate new Date(o.orderDate)
        numberOfItems: o.numberOfItems
        state: OrderStatus[o.state]
      @$el.html context orders: orders
      super
