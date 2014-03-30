require ['bootstrap'], ->
  require [
    './baseLibs'
    './social'
  ], ->
  require ['./logger'], (Logger, Social) ->
    Social.renderAll()
    logger = new Logger()
    logger.log category: 'navigation', action: "#{window.location.pathname}#{window.location.hash}", label: window?.location?.pathname?.substring(1), field: page: window?.location?.pathname
