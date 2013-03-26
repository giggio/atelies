define [
  'jquery'
  'Backbone'
  'views/AppView'
  'views/homeview'
],
($, Backbone, AppView, HomeView) ->
  class router extends Backbone.Router
    routes:
      '':'home'
      'home':'home'
    initialize: ->
      appView = new AppView el:$("#app-container")
      appView.render()
      Backbone.history.start()
    home: ->
      homeView = new HomeView el:$("#app-content")
      homeView.render()

