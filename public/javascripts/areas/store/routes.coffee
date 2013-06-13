define [
  'jquery'
  '../../viewsManager'
  './views/store'
  './views/product'
  './views/cart'
  './views/finishOrderShipping'
  './models/products'
  './models/store'
  './models/cart'
],($, viewsManager, StoreView, ProductView, CartView, FinishOrderShippingView, Products, Store, Cart) ->
  viewsManager.$el = $ '#app-container > .store'
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
  finishOrderShipping: ->
    store = storeBootstrapModel.store
    user = storeBootstrapModel.user
    finishOrderShippingView = new FinishOrderShippingView store: store, cart: Cart.get(store.slug), user: user
    viewsManager.show finishOrderShippingView
