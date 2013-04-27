define [
  'jquery'
  'backbone'
  'handlebars'
  'storeData'
  '../models/products'
  '../models/cart'
  'text!./templates/cart.html'
], ($, Backbone, Handlebars, storeData, Products, Cart, cartTemplate) ->
  class CartView extends Backbone.View
    storeData: storeData
    template: cartTemplate
    render: ->
      context = Handlebars.compile @template
      @$el.html context cartItems: Cart.get(@storeData.store.slug).items(), store: @storeData.store
