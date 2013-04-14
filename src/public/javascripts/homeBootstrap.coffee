define 'app', ['homeApp'], (HomeApp) ->
  class App
    start: -> new HomeApp()
require ['bootstrap']
