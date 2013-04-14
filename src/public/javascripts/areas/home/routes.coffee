define [
  'jquery'
  './views/Home'
],($, HomeView) ->
  home: ->
    homeView = new HomeView el:$("#app-container")
    homeView.render()
