define [
  'jquery'
  'backbone'
  'handlebars'
  'storeData'
  '../models/products'
  'text!./templates/product.html'
  '../models/cart'
], ($, Backbone, Handlebars, storeData, Products, productTemplate, Cart) ->
  class ProductView extends Backbone.View
    initialize: ->
      @cart = Cart.get()
    storeData: storeData
    template: productTemplate
    events: ->
      'click #purchaseItem':'purchase'
    purchase: ->
      @cart.addItem productId: @product.get('_id'), name: @product.get('name')
      Backbone.history.navigate '#cart', trigger: true
    render: (slug) ->
      @$el.empty()
      products = new Products @storeData.store.slug, slug
      products.fetch
        reset: true
        success: =>
          context = Handlebars.compile @template
          @product = products.first()
          @$el.html context product: @product.attributes, store: @storeData.store
        error: (collection, response, opt) =>
          console.error 'ERROR****************'
          console.error collection
          console.error response
          console.error opt
          console.error opt.xhr.error
