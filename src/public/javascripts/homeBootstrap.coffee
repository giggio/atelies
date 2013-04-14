define 'app', ['homeRouter'], (HomeRouter) ->
  start: -> new HomeRouter()
require ['bootstrap']
