define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  '../shared/views/dialog'
  './views/admin'
  './views/manageStore'
  './views/store'
  './views/manageProduct'
  './views/orders'
  './views/order'
  './models/products'
  './models/product'
  './models/stores'
  './models/store'
  './models/orders'
  './models/order'
],($, _, Backbone, viewsManager, Dialog, AdminView, ManageStoreView, StoreView, ManageProductView, OrdersView, OrderView, Products, Product, Stores, Store, Orders, Order) ->
  class Router extends Backbone.Open.Router
    area: 'admin'
    logCategory: 'admin'
    constructor: ->
      viewsManager.$el = $ "#app-container > .admin"
      @_createRoutes
        '': @admin
        'home': @admin
        'createStore': @createStore
        'manageStore/:storeId': @manageStore
        'store/:storeSlug': @store
        'manageProduct/:storeSlug/:productId': @manageProduct
        'createProduct/:storeSlug': @createProduct
        'orders': @orders
        'orders/:orderId': @order
        'search/:searchTerm': @search
      _.bindAll @, _.functions(@)...
      super
    search: (searchTerm) -> window.location = "/search/#{searchTerm}"
    admin: ->
      homeView = new AdminView stores: adminStoresBootstrapModel.stores
      viewsManager.show homeView
    createStore: ->
      store = new Store()
      stores = new Stores [store]
      user = adminStoresBootstrapModel.user
      manageStoreView = new ManageStoreView store:store, user:user
      viewsManager.show manageStoreView
    manageStore: (storeId) ->
      return unless store = @_findStore storeId
      stores = new Stores [store]
      user = adminStoresBootstrapModel.user
      manageStoreView = new ManageStoreView store:stores.at(0), user:user
      viewsManager.show manageStoreView
    store: (storeSlug) ->
      return unless store = @_findStore storeSlug
      @_findProducts storeSlug, (err, products) ->
        if err?
          return Dialog.showError viewsManager.$el, "Não foi possível carregar os produtos da loja. Tente novamente mais tarde."
        storeView = new StoreView store: store, products: products
        viewsManager.show storeView
    manageProduct: (storeSlug, productId) ->
      return unless store = @_findStore storeSlug
      storeModel = new Store store
      @_findProduct storeSlug, productId, (product) ->
        manageProductView = new ManageProductView storeSlug: storeSlug, product: product, store: storeModel
        manageProductView.render()
        viewsManager.show manageProductView
    createProduct: (storeSlug) ->
      return unless store = @_findStore storeSlug
      product = new Product()
      products = new Products [product], storeSlug: storeSlug
      storeModel = new Store store
      manageProductView = new ManageProductView storeSlug: storeSlug, product: product, store: storeModel
      viewsManager.show manageProductView
    _findProducts: (storeSlug, cb) ->
      products = new Products storeSlug: storeSlug
      products.fetch
        reset: true
        success: -> cb null, products
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível carregar os produtos. Tente novamente mais tarde."
    _findProduct: (storeSlug, productId, cb) ->
      product = new Product _id: productId
      products = new Products [product], storeSlug: storeSlug
      callBackWhenChanged = ->
        product.unbind 'sync', callBackWhenChanged
        cb product
      product.bind 'sync', callBackWhenChanged
      product.fetch
        error: (model, res, opt) ->
          Dialog.showError viewsManager.$el, "Não foi possível carregar o produto. Tente novamente mais tarde."
    orders: ->
      orders = new Orders()
      orders.fetch
        success: ->
          ordersView = new OrdersView orders: orders.toJSON()
          viewsManager.show ordersView
        error: (col, xhr, opt) ->
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível carregar os pedidos. Tente novamente mais tarde."
    order: (_id) ->
      order = new Order _id: _id
      orders = new Orders [order]
      order.fetch
        success: (order, res, opt) ->
          orderView = new OrderView order: order.toJSON()
          viewsManager.show orderView
        error: (order, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível carregar o pedido. Tente novamente mais tarde."
    _findStore: (storeSlugOrId) ->
      store = _.findWhere adminStoresBootstrapModel.stores, slug: storeSlugOrId
      unless store then store = _.findWhere adminStoresBootstrapModel.stores, _id: storeSlugOrId
      if store?
        store
      else
        Backbone.history.navigate ''
        homeView = new AdminView stores: adminStoresBootstrapModel.stores, dialog: title: "Acesso negado", message: "Você não tem permissão para alterar essa loja. Entre em contato diretamente com o administrador."
        viewsManager.show homeView
        undefined
