define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  './views/store'
  './views/product'
  './views/cart'
  './views/finishOrderShipping'
  './views/finishOrderUpdateProfile'
  './views/finishOrderPayment'
  './views/finishOrderSummary'
  './views/finishOrderOrderFinished'
  './views/evaluations'
  './models/products'
  './models/store'
  './models/cart'
  './models/productsSearch'
  './models/storeEvaluations'
  '../shared/views/dialog'
],($, _, Backbone, viewsManager, StoreView, ProductView, CartView, FinishOrderShippingView, FinishOrderUpdateProfileView, FinishOrderPaymentView, FinishOrderSummaryView, FinishOrderOrderFinishedView, EvaluationsView, Products, Store, Cart, ProductsSearch, StoreEvaluations, Dialog) ->
  class Router extends Backbone.Open.Router
    area: 'store'
    logCategory: 'store'
    constructor: ->
      viewsManager.$el = $ '#app-container > .store'
      @_createRoutes
        '': @home
        'cart': @cart
        'evaluations': @evaluations
        ':productSlug': @product
        'finishOrder/shipping': @finishOrderShipping
        'finishOrder/updateProfile': @finishOrderUpdateProfile
        'finishOrder/payment': @finishOrderPayment
        'finishOrder/summary': @finishOrderSummary
        'finishOrder/orderFinished': @finishOrderOrderFinished
        'searchProducts/:searchTerm': @searchProducts
      _.bindAll @
      super
    home: ->
      store = storeBootstrapModel.store
      user = storeBootstrapModel.user
      products = storeBootstrapModel.products
      @storeView = new StoreView store: store, products: products, user: user
      viewsManager.show @storeView
    product: (slug) ->
      store = storeBootstrapModel.store
      user = storeBootstrapModel.user
      otherProducts = storeBootstrapModel.products
      products = new Products store.slug, slug
      products.fetch
        reset: true
        success: =>
          product = products.first()
          productView = new ProductView store: store, product: product, user: user, products: otherProducts
          viewsManager.show productView
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível obter os produtos. Tente novamente mais tarde."
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
    searchProducts: (searchTerm) =>
      @home() unless @storeView?
      storeSlug = storeBootstrapModel.store.slug
      productsSearch = new ProductsSearch storeSlug: storeSlug, searchTerm:searchTerm
      productsSearch.fetch
        reset:true
        success: => @storeView.showProductsSearchResults searchTerm, productsSearch.toJSON()
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível realizar a busca. Tente novamente mais tarde."
    evaluations: ->
      store = storeBootstrapModel.store
      evaluations = new StoreEvaluations storeId: store._id
      evaluations.fetch
        reset: true
        success: =>
          evaluationsView = new EvaluationsView store: store, evaluations: evaluations.toJSON()
          viewsManager.show evaluationsView
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível obter as avaliações. Tente novamente mais tarde."
