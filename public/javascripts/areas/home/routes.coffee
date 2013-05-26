define [
  'jquery'
  '../../viewsManager'
  './views/home'
],($, viewsManager, HomeView) ->
  viewsManager.$el = $ "#app-container"
  home: ->
    homeView = new HomeView products: homeProductsBootstrapModel, stores: homeStoresBootstrapModel
    viewsManager.show homeView
