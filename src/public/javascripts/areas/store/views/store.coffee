define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/store.html'
], ($, Backbone, Handlebars, storeTemplate) ->
  class StoreView extends Backbone.View
    template: storeTemplate
    initialize: (opt) ->
      @store = opt.store
      @products = opt.products
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context store: @store, products: @products
