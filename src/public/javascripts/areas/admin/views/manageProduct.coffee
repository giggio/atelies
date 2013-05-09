define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/manageProduct.html'
  '../models/product'
  '../models/products'
], ($, Backbone, Handlebars, _, manageProductTemplate, Product, Products) ->
  class ManageProductView extends Backbone.View
    @justCreated: false
    template: manageProductTemplate
    initialize: (opt) =>
      @storeSlug = opt.storeSlug
      @productId = opt.productId
    render: =>
      if @product?
        context = Handlebars.compile @template
        @$el.html context product:@product.attributes
      else
        @_findProduct()
    _findProduct: (cb) =>
      @product = new Product _id: @productId
      @products = new Products [@product], storeSlug: @storeSlug
      @product.bind 'change', @render
      @product.fetch()
