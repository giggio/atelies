require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require ['areas/account/router'], (Router) -> new Router()
