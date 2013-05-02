define [
  'jquery'
  './views/admin'
  './views/createStore'
],($, AdminView, CreateStoreView) ->
  admin: ->
    homeView = new AdminView el:$("#app-container")
    homeView.render()
  createStore: ->
    createStoreView = new CreateStoreView el:$("#app-container")
    createStoreView.render()
