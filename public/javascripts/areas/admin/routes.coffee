define [
  'jquery'
  '../../viewsManager'
  './views/admin'
  './views/createStore'
  './views/store'
  './views/manageProduct'
  './models/products'
  './models/product'
],($, viewsManager, AdminView, CreateStoreView, StoreView, ManageProductView, Products, Product) ->
  class Routes
    viewsManager.$el = $ "#app-container"
    @admin: =>
      homeView = new AdminView stores: adminStoresBootstrapModel.stores
      viewsManager.show homeView
    @createStore: =>
      createStoreView = new CreateStoreView
      viewsManager.show createStoreView
    @store: (storeSlug) =>
      store = _.findWhere adminStoresBootstrapModel.stores, slug: storeSlug
      @_findProducts storeSlug, (err, products) ->
        storeView = new StoreView store: store, products: products
        viewsManager.show storeView
    @manageProduct: (storeSlug, productId) =>
      @_findProduct storeSlug, productId, (product) ->
        manageProductView = new ManageProductView storeSlug: storeSlug, product: product
        manageProductView.render()
        viewsManager.show manageProductView
    @createProduct: (storeSlug) =>
      product = new Product()
      products = new Products [product], storeSlug: storeSlug
      manageProductView = new ManageProductView storeSlug: storeSlug, product: product
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
