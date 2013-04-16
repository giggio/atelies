define [
  'jquery'
  'backbone'
  'handlebars'
  'storeData'
  '../models/products'
  'text!./templates/product.html'
], ($, Backbone, Handlebars, storeData, Products, productTemplate) ->
  class ProductView extends Backbone.View
    template: productTemplate
    render: (slug) ->
      @$el.empty()
      products = new Products storeData.store.slug, slug
      products.fetch
        reset: true
        success: =>
          context = Handlebars.compile @template
          product = products.first()
          @$el.html context product.attributes
        error: (collection, response, opt) =>
          console.error 'ERROR****************'
          console.error collection
          console.error response
          console.error opt
          console.error opt.xhr.error
