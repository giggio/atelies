define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/orderStatus'
  'text!./templates/order.html'
  '../../../converters'
], ($, _, Backbone, Handlebars, OrderStatus, orderTemplate, converters) ->
  class OrderView extends Backbone.Open.View
    events:
      'click #changeOrderStatus': '_enableUpdateOrderStatus'
      'click #doChangeOrderStatus': '_saveOrderStatus'
    template: orderTemplate
    initialize: (opt) ->
      @order = opt.order
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      order = @order
      order.shippingCost = converters.currency order.shippingCost
      order.totalSaleAmount = converters.currency order.totalSaleAmount
      order.totalProductsPrice = converters.currency order.totalProductsPrice
      order.orderDate = converters.prettyDate new Date(order.orderDate)
      order.items = _.map @order.items, (i) ->
        _id: i._id
        storeSlug: order.storeSlug
        slug: i.slug
        name: i.name
        picture: i.picture
        price: converters.currency i.price
        quantity: i.quantity
        totalPrice: converters.currency i.totalPrice
      @$el.html context order: order, orderState: OrderStatus[order.state], orderStatus: OrderStatus
      @_disableUpdateOrderStatus()
    _saveOrderStatus: ->
      $('#orderState').text OrderStatus[$('#changeState').val()]
      @_disableUpdateOrderStatus()
    _disableUpdateOrderStatus: ->
      $('#changeOrderStatus').show()
      $('#doChangeOrderStatus').hide()
      $('#orderState').show()
      $('#changeStateHolder').hide()
    _enableUpdateOrderStatus: (e) ->
      e.preventDefault()
      $('#changeOrderStatus').hide()
      $('#doChangeOrderStatus').show()
      $('#orderState').hide()
      $('#changeStateHolder').show()
