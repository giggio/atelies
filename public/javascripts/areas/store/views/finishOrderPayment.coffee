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
      if @cart.autoCalculatedShipping and @cart.shippingCalculated() is false
        return Backbone.history.navigate 'finishOrder/shipping', trigger: true
      context = Handlebars.compile @template
      numberOfProducts = @cart.items().length
      hasAutoCalculatedShipping = @cart.shippingSelected()
      if hasAutoCalculatedShipping
        shippingCost = converters.currency @cart.shippingCost()
      else
        shippingCost = "Calculado posteriormente"
      orderSummary =
        shippingCost: shippingCost
        productsInfo: "#{numberOfProducts} produto#{if numberOfProducts > 1 then 's' else ''}"
        totalProductsPrice: converters.currency @cart.totalPrice()
        totalSaleAmount: converters.currency @cart.totalSaleAmount()
      viewModel = user: @user, cart: @cart, store: @store, orderSummary: orderSummary, hasAutoCalculatedShipping: hasAutoCalculatedShipping
      if hasAutoCalculatedShipping
        viewModel.shippingOption = @cart.shippingOptionSelected()
        viewModel.shippingOptionPlural = viewModel.shippingOption.days > 1
      @$el.html context viewModel
    finishOrder: ->
      items = _.map @cart.items(), (i) -> _id: i._id, quantity: i.quantity
      orders = new Orders storeId: @store._id
      success = =>
        @cart.clear()
        Backbone.history.navigate 'finishOrder/orderFinished', trigger: true
      error = => #console.error 'Erro ao salvar'
      order = orders.create items:items, {error: error, success: success}
