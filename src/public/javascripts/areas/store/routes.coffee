define [
  'jquery'
  './views/store'
  './views/product'
  './views/cart'
  './models/products'
  './models/store'
],($, StoreView, ProductView, CartView, Products, Store) ->
  home: ->
    store = storeBootstrapModel.store
    products = storeBootstrapModel.products
    storeView = new StoreView el:$("#app-container"), store: store, products: products
    storeView.render()
  product: (slug) ->
    store = storeBootstrapModel.store
    products = new Products store.slug, slug
    products.fetch
      reset: true
      success: =>
        product = products.first()
        productView = new ProductView el:$('#app-container'), store: store, product: product
        productView.render()
  cart: ->
    store = storeBootstrapModel.store
    cartView = new CartView el:$('#app-container'), store: store
    cartView.render()
