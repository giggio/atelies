define [
  'jquery'
  'underscore'
  'backbone'
  'handlebars'
  '../models/productsHome'
  'text!./templates/home.html'
  './homeStores'
  './homeProducts'
], ($, _, Backbone, Handlebars, ProductsHome, homeTemplate, StoresView, ProductsView) ->
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
      @_showStores()
      @_showProducts()
    searchStores: ->
      @$('#searchStores').show('slow')
    closeSearchStore: ->
      @$('#searchStores').hide('fade')
      Backbone.history.navigate ""
    _doSearch: ->
      searchTerm = @$('#storeSearchTerm').val()
      return if searchTerm is ''
      Backbone.history.navigate "searchStores/#{searchTerm}", trigger:true
    showSearchResults: (searchTerm) ->
      @$('#storeSearchTerm').val searchTerm
      @$('#productsPlaceHolder').empty()
      @_showStores searchTerm
    _showStores: (searchTerm) ->
      if searchTerm?
        #TODO actually search
        @stores.pop()
        @stores.pop()
        stores = @stores
      stores = @stores
      @storesView = new StoresView stores:stores
      @$('#storesPlaceHolder').html @storesView.el
    _showProducts: ->
      @productsView = new ProductsView products:@products
      @$('#productsPlaceHolder').html @productsView.el
