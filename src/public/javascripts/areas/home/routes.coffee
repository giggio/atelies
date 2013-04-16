define [
  'jquery'
  './views/home'
],($, HomeView) ->
  home: ->
    homeView = new HomeView el:$("#app-container")
    homeView.render()
