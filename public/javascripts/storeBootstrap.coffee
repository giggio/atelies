require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require ['areas/store/router'], (Router) -> new Router()
