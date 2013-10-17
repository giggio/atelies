require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require [
    'areas/account/router'
    'areas/account/serverInfo'
  ], (Router, serverInfo) -> new Router serverInfo: serverInfo
