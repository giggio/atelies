define [
  'jquery'
  './views/home'
],($, HomeView) ->
  home: ->
    homeView = new HomeView el:$("#app-container"), products: homeProductsBootstrapModel
    homeView.render()
