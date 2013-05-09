define [
  'jquery'
  './views/admin'
  './views/createStore'
  './views/manageStore'
  './views/manageProduct'
],($, AdminView, CreateStoreView, ManageStoreView, ManageProductView) ->
  admin: ->
    homeView = new AdminView el:$ "#app-container"
    homeView.render()
  createStore: ->
    createStoreView = new CreateStoreView el:$ "#app-container"
    createStoreView.render()
  manageStore: (storeSlug) ->
    manageStoreView = new ManageStoreView el:$("#app-container"), storeSlug: storeSlug
    manageStoreView.render()
  manageProduct: (storeSlug, productId) ->
    manageProductView = new ManageProductView el:$('#app-container'), storeSlug: storeSlug, productId: productId
    manageProductView.render()
