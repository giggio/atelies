define [
  'jquery'
  './views/store'
  './views/product'
],($, StoreView, ProductView) ->
  home: ->
    storeView = new StoreView el:$ "#app-container"
    storeView.render()
  product: (slug) ->
    productView = new ProductView el:$ '#app-container'
    productView.render slug
