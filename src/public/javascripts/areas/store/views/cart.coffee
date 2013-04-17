define [
  'jquery'
  'backbone'
  'handlebars'
  'storeData'
  '../models/products'
  'text!./templates/cart.html'
], ($, Backbone, Handlebars, storeData, Products, cartTemplate) ->
  class CartView extends Backbone.View
    storeData: storeData
    template: cartTemplate
    render: ->
      context = Handlebars.compile @template
      @$el.html context []
