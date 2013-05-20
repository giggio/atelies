define [
  'jquery'
  'backbone'
  'handlebars'
  'underscore'
  'text!./templates/manageStore.html'
  '../models/products'
], ($, Backbone, Handlebars, _, manageStoreTemplate, Products) ->
  class ManageStoreView extends Backbone.View
    @justCreated: false
    template: manageStoreTemplate
    initialize: (opt) =>
      @products = opt.products
      @store = opt.store
    render: =>
      [justCreated, ManageStoreView.justCreated] = [ManageStoreView.justCreated, off]
      context = Handlebars.compile @template
      @$el.html context store:@store, products:@products.toJSON(), justCreated:justCreated
