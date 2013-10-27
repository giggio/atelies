define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/home.html'
  './homeStores'
  './homeProducts'
  './homeProductsSearchResults'
], ($, _, Backbone, Handlebars, homeTemplate, StoresView, ProductsView, ProductsSearchResultsView) ->
  class HomeView extends Backbone.Open.View
    events:
      'click #doSearch':'_doSearch'
      'keypress #storeSearchTerm':'_searchTermPressed'
    template: homeTemplate
    initialize: (opt) ->
      @products = opt.products
      @stores = opt.stores
      @showProductsAndStores()
      document.title = "Ateliês - Shopping virtual de artes e afins"
    showProductsAndStores: ->
      context = Handlebars.compile @template
      @$el.html context
      @_showStoresView @stores
      @_showProductsView @products
    searchStores: ->
      @$('#searchStores').attr('style', 'display:block !important;').show()
      document.title = "Ateliês - busca por lojas"
    closeSearchStore: ->
      @$('#searchStores').hide('fade')
      Backbone.history.navigate "", true
    _searchTermPressed: (e) -> @_doSearch() if e.keyCode is 13
    _doSearch: ->
      searchTerm = @$('#storeSearchTerm').val()
      return if searchTerm is ''
      Backbone.history.navigate "searchStores/#{searchTerm}", trigger:true
    showStoresSearchResults: (searchTerm, stores) ->
      @$('#storeSearchTerm').val searchTerm
      @$('#productsPlaceHolder').empty()
      @_showStoresView stores
      document.title = "Ateliês - busca por lojas: #{searchTerm}"
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
      document.title = "Ateliês - busca por produtos: #{searchTerm}"
