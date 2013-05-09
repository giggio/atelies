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
      @store = _.findWhere adminStoresBootstrapModel.stores, slug: opt.storeSlug
    render: =>
      justCreated = ManageStoreView.justCreated
      ManageStoreView.justCreated = off
      @_findProducts @store, (err, products) =>
        context = Handlebars.compile @template
        return @$el.html context error:err if err?
        @$el.html context store:@store, products:products.toJSON(), justCreated:justCreated
    _findProducts: (store, cb) =>
      products = new Products storeSlug: store.slug
      products.fetch
        reset: true
        success: -> cb null, products
        error: (col, res, opt) -> cb "Error: #{opt?xhr?.error}"
