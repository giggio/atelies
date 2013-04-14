define 'app', ['areas/home/homeRouter'], (HomeRouter) ->
  start: -> new HomeRouter()
require ['bootstrap']
