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
      @product = opt.product
    render: =>
      context = Handlebars.compile @template
      @$el.html context product: @product.attributes
