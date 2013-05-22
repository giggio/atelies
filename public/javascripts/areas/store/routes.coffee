define [
  'jquery'
  '../../viewsManager'
  './views/store'
  './views/product'
  './views/cart'
  './models/products'
  './models/store'
],($, viewsManager, StoreView, ProductView, CartView, Products, Store) ->
  viewsManager.$el = $ "#app-container"
  home: ->
    store = storeBootstrapModel.store
    products = storeBootstrapModel.products
    storeView = new StoreView store: store, products: products
    viewsManager.show storeView
  product: (slug) ->
    store = storeBootstrapModel.store
    products = new Products store.slug, slug
    products.fetch
      reset: true
      success: =>
        product = products.first()
        productView = new ProductView store: store, product: product
        viewsManager.show productView
  cart: ->
    store = storeBootstrapModel.store
    cartView = new CartView store: store
    viewsManager.show cartView
