define [
  'jquery'
  '../../viewsManager'
  './views/home'
],($, viewsManager, HomeView) ->
  viewsManager.$el = $ "#app-container"
  home: ->
    homeView = new HomeView products: homeProductsBootstrapModel, productsFeatured: homeProductsFeaturedBootstrapModel, stores: homeStoresBootstrapModel
    viewsManager.show homeView
