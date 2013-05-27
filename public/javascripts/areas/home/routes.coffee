define [
  'jquery'
  '../../viewsManager'
  './views/home'
],($, viewsManager, HomeView) ->
  class Routes
    viewsManager.$el = $ "#app-container"
    @home: =>
      @homeView = new HomeView products: homeProductsBootstrapModel, stores: homeStoresBootstrapModel
      viewsManager.show @homeView
    @searchStores: =>
      unless @homeView?
        @home()
      @homeView.searchStores()
    @closeSearchStore: =>
      @homeView.closeSearchStore()
    @searchStore: (searchTerm) =>
      unless @homeView?
        @home()
        @searchStores()
      @homeView.showSearchResults searchTerm
