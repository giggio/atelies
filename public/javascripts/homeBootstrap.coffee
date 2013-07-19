require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require ['areas/home/router'], (Router) -> new Router()
