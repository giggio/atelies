define [
  'jquery'
  'Backbone'
  'views/homeview'
],
($, Backbone, HomeView) ->
  class router extends Backbone.Router
    routes:
      '':'home'
      'home':'home'
    initialize: ->
      Backbone.history.start()
    home: ->
      homeView = new HomeView el:$("#app-container")
      homeView.render()

