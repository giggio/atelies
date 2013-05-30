define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/store.html'
  '../models/products'
], ($, Backbone, Handlebars, _, storeTemplate, Products) ->
  class StoreView extends Backbone.View
    @justCreated: false
    template: storeTemplate
    initialize: (opt) =>
      @products = opt.products
      @store = opt.store
    render: =>
      [justCreated, StoreView.justCreated] = [StoreView.justCreated, off]
      context = Handlebars.compile @template
      @$el.html context store:@store, products:@products.toJSON(), justCreated:justCreated
