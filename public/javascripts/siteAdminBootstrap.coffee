require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require ['areas/siteAdmin/router'], (Router) -> new Router()
