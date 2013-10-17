require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require [
    'areas/admin/router'
    'areas/admin/serverInfo'
  ], (Router, serverInfo) -> new Router serverInfo: serverInfo
