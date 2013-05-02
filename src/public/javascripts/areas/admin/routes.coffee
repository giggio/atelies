define [
  'jquery'
  './views/admin'
  './views/createStore'
  './views/manageStore'
],($, AdminView, CreateStoreView, ManageStoreView) ->
  admin: ->
    homeView = new AdminView el:$ "#app-container"
    homeView.render()
  createStore: ->
    createStoreView = new CreateStoreView el:$ "#app-container"
    createStoreView.render()
  manageStore: (storeSlug) ->
    manageStoreView = new ManageStoreView el:$("#app-container"), storeSlug: storeSlug
    manageStoreView.render()
