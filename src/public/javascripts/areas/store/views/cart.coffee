define [
  'jquery'
  'backbone'
  'handlebars'
  'storeData'
  '../models/products'
  '../models/cart'
  'text!./templates/cart.html'
  './cartItem'
], ($, Backbone, Handlebars, storeData, Products, Cart, cartTemplate, CartItemView) ->
  class CartView extends Backbone.View
    storeData: storeData
    template: cartTemplate
    initialize: (opt) =>
      @storeData = opt.storeData if opt.storeData?
      @cart = Cart.get(@storeData.store.slug)
    render: =>
      context = Handlebars.compile @template
      @$el.html context cartItems: Cart.get(@storeData.store.slug).items(), store: @storeData.store
      @renderCartItems()
    renderCartItems: =>
      for item in @cart.items()
        cartItemView = new CartItemView el:$('#cartItems > tbody', @$el), model: item
        cartItemView.render()
        cartItemView.removed @remove
    remove: (item) =>
      @removeById item._id
    removeById: (id) =>
      @cart.removeById id
      @render()
