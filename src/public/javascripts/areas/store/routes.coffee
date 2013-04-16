define [
  'jquery'
  './views/store'
  './views/product'
],($, StoreView, ProductView) ->
  home: ->
    storeView = new StoreView el:$ "#app-container"
    storeView.render()
  product: (storeSlug, productSlug) ->
    productView = new ProductView el:$ '#app-container'
    productView.render productSlug
