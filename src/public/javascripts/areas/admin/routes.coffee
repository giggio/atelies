define [
  'jquery'
  './views/admin'
],($, AdminView) ->
  admin: ->
    homeView = new AdminView el:$("#app-container")
    homeView.render()
