require ['bootstrap'], ->
  require [
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], ->
  require ['./logger'], (Logger) ->
    logger = new Logger()
    logger.log category: 'navigation', action: "#{window.location.pathname}#{window.location.hash}", label: window?.location?.pathname?.substring(1), field: page: window?.location?.pathname
