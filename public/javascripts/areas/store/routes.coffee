define [
  'jquery'
  '../../viewsManager'
  './views/store'
  './views/product'
  './views/cart'
  './views/finishOrderShipping'
  './views/finishOrderUpdateProfile'
  './views/finishOrderPayment'
  './views/finishOrderSummary'
  './views/finishOrderOrderFinished'
  './models/products'
  './models/store'
  './models/cart'
],($, viewsManager, StoreView, ProductView, CartView, FinishOrderShippingView, FinishOrderUpdateProfileView, FinishOrderPaymentView, FinishOrderSummaryView, FinishOrderOrderFinishedView, Products, Store, Cart) ->
  class Routes extends Backbone.Open.Routes
    constructor: ->
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
    finishOrderUpdateProfile: ->
      store = storeBootstrapModel.store
      user = storeBootstrapModel.user
      finishOrderUpdateProfileView = new FinishOrderUpdateProfileView user: user, store: store
      viewsManager.show finishOrderUpdateProfileView
    finishOrderPayment: ->
      store = storeBootstrapModel.store
      user = storeBootstrapModel.user
      cart = Cart.get store.slug
      finishOrderPaymentView = new FinishOrderPaymentView store: store, cart: cart, user: user
      viewsManager.show finishOrderPaymentView
    finishOrderSummary: ->
      store = storeBootstrapModel.store
      user = storeBootstrapModel.user
      cart = Cart.get store.slug
      finishOrderSummaryView = new FinishOrderSummaryView store: store, cart: cart, user: user
      viewsManager.show finishOrderSummaryView
    finishOrderOrderFinished: ->
      finishOrderOrderFinishedView = new FinishOrderOrderFinishedView()
      viewsManager.show finishOrderOrderFinishedView
  new Routes()
