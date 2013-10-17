require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require [
    'areas/store/router'
    'areas/store/serverInfo'
  ], (Router, serverInfo) -> new Router serverInfo: serverInfo
