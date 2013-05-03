define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/store'
  'text!./templates/store.html'
], ($, Backbone, Handlebars, Store, storeTemplate) ->
  class StoreView extends Backbone.View
    template: storeTemplate
    render: ->
      @$el.empty()
      store = null
      if storeBootstrapModel?.store?
        store = new Store storeBootstrapModel.store
        store = store.toJSON()
      context = Handlebars.compile @template
      @$el.html context {store: store, products: storeBootstrapModel.products}
