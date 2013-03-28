define [
  'jquery'
  'views/homeview'
],($, HomeView) ->
  class Routes
    home: ->
      homeView = new HomeView el:$("#app-container")
      homeView.render()
  new Routes()

