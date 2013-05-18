define [
  'jquery'
  './views/admin'
  './views/createStore'
  './views/manageStore'
  './views/manageProduct'
  './models/products'
  './models/product'
],($, AdminView, CreateStoreView, ManageStoreView, ManageProductView, Products, Product) ->
  class Routes
    @admin: =>
      homeView = new AdminView el:$("#app-container"), stores: adminStoresBootstrapModel.stores
      homeView.render()
    @createStore: =>
      createStoreView = new CreateStoreView el:$("#app-container")
      createStoreView.render()
    @manageStore: (storeSlug) =>
      store = _.findWhere adminStoresBootstrapModel.stores, slug: storeSlug
      @_findProducts storeSlug, (err, products) ->
        manageStoreView = new ManageStoreView el:$("#app-container"), store: store, products: products
        manageStoreView.render()
    @manageProduct: (storeSlug, productId) =>
      @_findProduct storeSlug, productId, (product) ->
        manageProductView = new ManageProductView el:$('#app-container'), storeSlug: storeSlug, product: product
        manageProductView.render()
    @createProduct: (storeSlug) =>
      product = new Product()
      products = new Products [product], storeSlug: storeSlug
      manageProductView = new ManageProductView el:$('#app-container'), storeSlug: storeSlug, product: product
      manageProductView.render()

    @_findProducts: (storeSlug, cb) =>
      products = new Products storeSlug: storeSlug
      products.fetch
        reset: true
        success: -> cb null, products
        error: (col, res, opt) -> cb "Error: #{opt?xhr?.error}"
    @_findProduct: (storeSlug, productId, cb) =>
      product = new Product _id: productId
      products = new Products [product], storeSlug: storeSlug
      callBackWhenChanged = ->
        product.unbind 'sync', callBackWhenChanged
        cb product
      product.bind 'sync', callBackWhenChanged
      product.fetch()
