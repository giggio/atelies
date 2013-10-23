define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  './views/home'
  './models/storesSearch'
  './models/productsSearch'
  '../shared/views/dialog'
],($, _, Backbone, viewsManager, HomeView, StoresSearch, ProductsSearch, Dialog) ->
  class Router extends Backbone.Open.Router
    logCategory: 'home'
    area: 'home'
    constructor: ->
      @_createRoutes
        '': @home
        'home': @home
        'searchStores': @searchStores
        'closeSearchStore': @closeSearchStore
        'searchStores/:searchTerm': @searchStore
        'searchProducts/:searchTerm': @searchProducts
      viewsManager.$el = $ "#app-container > .home"
      _.bindAll @, _.functions(@)...
      super
    home: ->
      @homeView = new HomeView products: homeProductsBootstrapModel, stores: homeStoresBootstrapModel
      viewsManager.show @homeView
    searchStores: ->
      @home() unless @homeView?
      @homeView.searchStores()
    closeSearchStore: ->
      @homeView.closeSearchStore()
    searchStore: (searchTerm) =>
      unless @homeView?
        @home()
        @searchStores()
      storesSearch = new StoresSearch searchTerm:searchTerm
      storesSearch.fetch
        reset:true
        success: => @homeView.showStoresSearchResults searchTerm, storesSearch.toJSON()
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível realizar a busca. Tente novamente mais tarde."
    searchProducts: (searchTerm) ->
      @home() unless @homeView?
      productsSearch = new ProductsSearch searchTerm:searchTerm
      productsSearch.fetch
        reset:true
        success: => @homeView.showProductsSearchResults searchTerm, productsSearch.toJSON()
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível realizar a busca. Tente novamente mais tarde."
