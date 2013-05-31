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
    @justUpdated: false
    template: storeTemplate
    initialize: (opt) =>
      @products = opt.products
      @store = opt.store
    render: =>
      [justCreated, StoreView.justCreated, justUpdated, StoreView.justUpdated] = [StoreView.justCreated, off, StoreView.justUpdated, off]
      context = Handlebars.compile @template
      @$el.html context store:@store, products:@products.toJSON(), justCreated:justCreated, justUpdated:justUpdated
