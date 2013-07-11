define [
  'jquery'
  'backbone'
  'handlebars'
  './storeProducts'
  'text!./templates/store.html'
  './productsSearchResults'
], ($, Backbone, Handlebars, ProductsView, storeTemplate, ProductsSearchResultsView) ->
  class StoreView extends Backbone.View
    template: storeTemplate
    initialize: (opt) ->
      @store = opt.store
      @products = opt.products
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context store: @store
      @productsView = new ProductsView products:@products
      @$('#productsPlaceHolder').html @productsView.el
    showProductsSearchResults: (searchTerm, products) ->
      $('#productSearchTerm').val searchTerm
      productsSearchResultsView = new ProductsSearchResultsView products:products
      @$('#productsPlaceHolder').html productsSearchResultsView.el
