define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  'text!./templates/home.html'
  './homeStores'
  './homeProducts'
  './homeProductsSearchResults'
], ($, _, Backbone, Handlebars, homeTemplate, StoresView, ProductsView, ProductsSearchResultsView) ->
  class HomeView extends Backbone.View
    events:
      'click #doSearch':'_doSearch'
    template: homeTemplate
    initialize: (opt) ->
      @products = opt.products
      @stores = opt.stores
      @showProductsAndStores()
    showProductsAndStores: ->
      context = Handlebars.compile @template
      @$el.html context
      @_showStoresView @stores
      @_showProductsView @products
    searchStores: ->
      @$('#searchStores').show('slow')
    closeSearchStore: ->
      @$('#searchStores').hide('fade')
      Backbone.history.navigate ""
    _doSearch: ->
      searchTerm = @$('#storeSearchTerm').val()
      return if searchTerm is ''
      Backbone.history.navigate "searchStores/#{searchTerm}", trigger:true
    showStoresSearchResults: (searchTerm, stores) ->
      @$('#storeSearchTerm').val searchTerm
      @$('#productsPlaceHolder').empty()
      @_showStoresView stores
    _showStoresView: (stores) ->
      @storesView = new StoresView stores:stores
      @$('#storesPlaceHolder').html @storesView.el
    _showProductsView: (products) ->
      @productsView = new ProductsView products:products
      @$('#productsPlaceHolder').html @productsView.el
    _showProductsSearchResultView: (products) ->
      @productsSearchResultsView = new ProductsSearchResultsView products:products
      @$('#productsPlaceHolder').html @productsSearchResultsView.el
    showProductsSearchResults: (searchTerm, products) ->
      $('#productSearchTerm').val searchTerm
      @$('#storesPlaceHolder').empty()
      @_showProductsSearchResultView products
