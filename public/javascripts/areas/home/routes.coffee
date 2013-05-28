define [
  'jquery'
  '../../viewsManager'
  './views/home'
  './models/storesSearch'
  './models/productsSearch'
],($, viewsManager, HomeView, StoresSearch, ProductsSearch) ->
  class Routes
    viewsManager.$el = $ "#app-container"
    @home: =>
      @homeView = new HomeView products: homeProductsBootstrapModel, stores: homeStoresBootstrapModel
      viewsManager.show @homeView
    @searchStores: =>
      @home() unless @homeView?
      @homeView.searchStores()
    @closeSearchStore: =>
      @homeView.closeSearchStore()
    @searchStore: (searchTerm) =>
      unless @homeView?
        @home()
        @searchStores()
      storesSearch = new StoresSearch searchTerm:searchTerm
      storesSearch.fetch
        reset:true
        success: => @homeView.showStoresSearchResults searchTerm, storesSearch.toJSON()
    @searchProducts: (searchTerm) =>
      @home() unless @homeView?
      productsSearch = new ProductsSearch searchTerm:searchTerm
      productsSearch.fetch
        reset:true
        success: => @homeView.showProductsSearchResults searchTerm, productsSearch.toJSON()
