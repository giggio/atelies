define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/products'
  '../models/cart'
  '../models/orders'
  '../models/order'
  'text!./templates/finishOrderSummary.html'
  './cartItem'
  '../../../converters'
], ($, _, Backbone, Handlebars, Products, Cart, Orders, Order, finishOrderSummaryTemplate, CartItemView, converters) ->
  class FinishOrderPayment extends Backbone.View
    events:
      'click #finishOrder':'finishOrder'
    template: finishOrderSummaryTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
    render: =>
      if @cart.autoCalculatedShipping and @cart.shippingCalculated() is false
        return Backbone.history.navigate 'finishOrder/shipping', trigger: true
      context = Handlebars.compile @template
      numberOfProducts = @cart.items().length
      @hasAutoCalculatedShipping = @cart.shippingSelected()
      if @hasAutoCalculatedShipping
        shippingCost = converters.currency @cart.shippingCost()
      else
        shippingCost = "Calculado posteriormente"
      orderSummary =
        shippingCost: shippingCost
        productsInfo: "#{numberOfProducts} produto#{if numberOfProducts > 1 then 's' else ''}"
        totalProductsPrice: converters.currency @cart.totalPrice()
        totalSaleAmount: converters.currency @cart.totalSaleAmount()
      viewModel = user: @user, cart: @cart, store: @store, orderSummary: orderSummary, hasAutoCalculatedShipping: @hasAutoCalculatedShipping, paymentType: @cart.paymentTypeSelected().name
      if @hasAutoCalculatedShipping
        viewModel.shippingOption = @cart.shippingOptionSelected()
        viewModel.shippingOptionPlural = viewModel.shippingOption.days > 1
      @$el.html context viewModel
    finishOrder: ->
      items = _.map @cart.items(), (i) -> _id: i._id, quantity: i.quantity
      orders = new Orders storeId: @store._id
      success = (model, response, opt) =>
        @cart.clear()
        if @store.pagseguro
          window.location = response.redirect
        else
          Backbone.history.navigate 'finishOrder/orderFinished', trigger: true
      error = (model, xhr, opt) => console.error "Erro ao salvar #{xhr}"
      order = items: items
      order.shippingType = @cart.shippingOptionSelected().type if @hasAutoCalculatedShipping
      order = new Order order
      orders.add order
      order.save order.attributes, error: error, success: success
