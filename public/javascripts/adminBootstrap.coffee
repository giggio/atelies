require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require ['areas/admin/router'], (Router) -> new Router()
