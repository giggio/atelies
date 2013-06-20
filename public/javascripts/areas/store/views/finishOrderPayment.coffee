define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  '../models/orders'
  'text!./templates/finishOrderPayment.html'
  './cartItem'
  '../../../converters'
], ($, _, Backbone, Handlebars, Products, Cart, Orders, finishOrderPaymentTemplate, CartItemView, converters) ->
  class FinishOrderPayment extends Backbone.View
    events:
      'click #finishOrder':'finishOrder'
    template: finishOrderPaymentTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
    render: =>
      unless @cart.shippingCalculated()
        return Backbone.history.navigate 'finishOrder/shipping', trigger: true
      numberOfProducts = @cart.items().length
      orderSummary =
        shippingCost: converters.currency @cart.shippingCost()
        productsInfo: "#{numberOfProducts} produto#{if numberOfProducts > 1 then 's' else ''}"
        totalProductsPrice: converters.currency @cart.totalPrice()
        totalSaleAmount: converters.currency @cart.totalSaleAmount()
      shippingOption = @cart.shippingOptionSelected()
      context = Handlebars.compile @template
      @$el.html context user: @user, cart: @cart, store: @store, orderSummary: orderSummary, shippingOption: shippingOption, shippingOptionPlural: shippingOption.days > 1
    finishOrder: ->
      items = _.map @cart.items(), (i) -> _id: i._id, quantity: i.quantity
      orders = new Orders storeId: @store._id
      success = =>
        @cart.clear()
        Backbone.history.navigate 'finishOrder/orderFinished', trigger: true
      error = => #console.error 'Erro ao salvar'
      order = orders.create items:items, {error: error, success: success}
