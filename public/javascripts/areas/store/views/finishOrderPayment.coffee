define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/finishOrderPayment.html'
  './cartItem'
  '../../../converters'
], ($, _, Backbone, Handlebars, Products, Cart, finishOrderPaymentTemplate, CartItemView, converters) ->
  class FinishOrderPayment extends Backbone.View
    events:
      'click #finishOrder':'finishOrder'
    template: finishOrderPaymentTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
    render: =>
      numberOfProducts = @cart.items().length
      orderSummary =
        shippingCost: converters.currency @cart.shippingCost()
        productsInfo: "#{numberOfProducts} produto#{if numberOfProducts > 1 then 's'}"
        totalProductsPrice: converters.currency @cart.totalPrice()
        totalSaleAmount: converters.currency @cart.totalSaleAmount()
      context = Handlebars.compile @template
      @$el.html context user: @user, cart: @cart, store: @store, orderSummary: orderSummary
    finishOrder: ->
      Backbone.history.navigate 'finishOrder/orderFinished', trigger: true
