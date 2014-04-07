define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/home.html'
  './homeStores'
  './homeProducts'
  './homeSearchResults'
], ($, _, Backbone, Handlebars, homeTemplate, StoresView, ProductsView, SearchResultsView) ->
  class HomeView extends Backbone.Open.View
    template: homeTemplate
    initialize: (opt) ->
      @products = opt.products
      @stores = opt.stores
      @showProductsAndStores()
      document.title = "Ateliês - Shopping virtual de artes e afins"
    showProductsAndStores: ->
      context = Handlebars.compile @template
      @$('#searchPlaceHolder').empty()
      @$el.html context
      @_showStoresView @stores
      @_showProductsView @products
    _showStoresView: (stores) ->
      @storesView = new StoresView stores:stores
      @$('#storesPlaceHolder').html @storesView.el
    _showProductsView: (products) ->
      @productsView = new ProductsView products:products
      @$('#productsPlaceHolder').html @productsView.el
    showSearchResults: (searchTerm, productsAndStores) ->
      @$('#storesPlaceHolder').empty()
      @$('#productsPlaceHolder').empty()
      @productsSearchResultsView = new SearchResultsView productsAndStores
      @$('#searchPlaceHolder').html @productsSearchResultsView.el
      document.title = "Ateliês - busca por: #{searchTerm}"
