define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../../shared/views/dialog'
  '../models/orderStatus'
  'text!./templates/order.html'
  '../../../converters'
], ($, _, Backbone, Handlebars, Dialog, OrderStatus, orderTemplate, converters) ->
  class OrderView extends Backbone.Open.View
    events:
      'click #changeOrderStatus': '_enableUpdateOrderStatus'
      'click #doChangeOrderStatus': '_saveOrderStatus'
      'click #cancelChangeOrderStatus': '_cancelOrderStatus'
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
      newOrderState = $('#changeState').val()
      $.ajax
        type: 'PUT'
        url: "/api/admin/orders/#{@order._id}/state/#{newOrderState}"
      .done =>
        @order.state = newOrderState
        $('#orderState').text OrderStatus[newOrderState]
        @_disableUpdateOrderStatus()
      .fail => return Dialog.showError @$el, "Não foi possível alterar o estado do pedido. Tente novamente mais tarde."
    _disableUpdateOrderStatus: ->
      $('#changeOrderStatus,#orderState').show()
      $('#cancelChangeOrderStatus,#doChangeOrderStatus,#changeStateHolder').hide()
    _enableUpdateOrderStatus: (e) ->
      e.preventDefault()
      $('#changeOrderStatus,#orderState').hide()
      $('#cancelChangeOrderStatus,#doChangeOrderStatus,#changeStateHolder').show()
    _cancelOrderStatus: -> @_disableUpdateOrderStatus()
