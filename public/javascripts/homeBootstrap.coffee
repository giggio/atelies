require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require [
    'areas/home/router'
    'areas/home/serverInfo'
  ], (Router, serverInfo) -> new Router serverInfo: serverInfo
