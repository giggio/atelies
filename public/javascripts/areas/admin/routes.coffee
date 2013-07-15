define [
  'jquery'
  '../../viewsManager'
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
],($, viewsManager, AdminView, ManageStoreView, StoreView, ManageProductView, OrdersView, OrderView, Products, Product, Stores, Store, Orders, Order) ->
  class Routes
    viewsManager.$el = $ "#app-container > .admin"
    @admin: =>
      homeView = new AdminView stores: adminStoresBootstrapModel.stores
      viewsManager.show homeView
    @createStore: =>
      store = new Store()
      stores = new Stores [store]
      user = adminStoresBootstrapModel.user
      manageStoreView = new ManageStoreView store:store, user:user
      viewsManager.show manageStoreView
    @manageStore: (storeId) =>
      store = _.findWhere adminStoresBootstrapModel.stores, _id: storeId
      stores = new Stores [store]
      user = adminStoresBootstrapModel.user
      manageStoreView = new ManageStoreView store:stores.at(0), user:user
      viewsManager.show manageStoreView
    @store: (storeSlug) =>
      store = _.findWhere adminStoresBootstrapModel.stores, slug: storeSlug
      @_findProducts storeSlug, (err, products) ->
        storeView = new StoreView store: store, products: products
        viewsManager.show storeView
    @manageProduct: (storeSlug, productId) =>
      store = _.findWhere adminStoresBootstrapModel.stores, slug: storeSlug
      storeModel = new Store store
      @_findProduct storeSlug, productId, (product) ->
        manageProductView = new ManageProductView storeSlug: storeSlug, product: product, store: storeModel
        manageProductView.render()
        viewsManager.show manageProductView
    @createProduct: (storeSlug) =>
      product = new Product()
      products = new Products [product], storeSlug: storeSlug
      store = _.findWhere adminStoresBootstrapModel.stores, slug: storeSlug
      storeModel = new Store store
      manageProductView = new ManageProductView storeSlug: storeSlug, product: product, store: storeModel
      viewsManager.show manageProductView

    @_findProducts: (storeSlug, cb) =>
      products = new Products storeSlug: storeSlug
      products.fetch
        reset: true
        success: -> cb null, products
        error: (col, res, opt) -> cb "Error: #{opt?.xhr?.error}"
    @_findProduct: (storeSlug, productId, cb) =>
      product = new Product _id: productId
      products = new Products [product], storeSlug: storeSlug
      callBackWhenChanged = ->
        product.unbind 'sync', callBackWhenChanged
        cb product
      product.bind 'sync', callBackWhenChanged
      product.fetch()
    @orders: ->
      orders = new Orders()
      orders.fetch
        success: ->
          ordersView = new OrdersView orders: orders.toJSON()
          viewsManager.show ordersView
    @order: (_id) ->
      order = new Order _id: _id
      orders = new Orders [order]
      order.fetch
        success: (order, res, opt) ->
          orderView = new OrderView order: order.toJSON()
          viewsManager.show orderView
        error: (order, res, opt) ->
          console.log 'error loading order'
