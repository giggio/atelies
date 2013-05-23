define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/cart.html'
  './cartItem'
], ($, Backbone, Handlebars, Products, Cart, cartTemplate, CartItemView) ->
  class CartView extends Backbone.View
    events:
      'click #clearCart':'clear'
    template: cartTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = Cart.get(@store.slug)
    render: =>
      context = Handlebars.compile @template
      cartItems = Cart.get(@store.slug).items()
      @$el.html context cartItems: cartItems, store: @store, hasItems: cartItems.length isnt 0
      @renderCartItems()
    renderCartItems: =>
      for item in @cart.items()
        cartItemView = new CartItemView cartItem: item
        $('#cartItems > tbody', @$el).append cartItemView.$el
        cartItemView.removed @remove
        cartItemView.changed @change
    remove: (item) =>
      @removeById item._id
    removeById: (id) =>
      @cart.removeById id
      @render()
    change: =>
      @cart.save()
    clear: =>
      @cart.clear()
      @render()
