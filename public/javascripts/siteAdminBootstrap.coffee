require ['bootstrap'], ->
  require [
    './baseLibs'
  ], ->
  require [
    'areas/siteAdmin/router'
    'areas/siteAdmin/serverInfo'
  ], (Router, serverInfo) -> new Router serverInfo: serverInfo
