define [
  'jquery'
  'backbone'
  'handlebars'
  'storeData'
  '../models/store'
  'text!./templates/store.html'
], ($, Backbone, Handlebars, storeData, Store, storeTemplate) ->
  class StoreView extends Backbone.View
    template: storeTemplate
    render: ->
      @$el.empty()
      store = null
      unless storeData.store is null
        store = new Store storeData.store
        store = store.toJSON()
      context = Handlebars.compile @template
      @$el.html context {store: store, products: storeData.products}
