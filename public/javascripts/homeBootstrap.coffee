require ['bootstrap'], ->
  require [
    './backboneConfig'
    './loginPopover'
    './jqueryValidationExt'
  ], ->
  require ['areas/home/router'], (Router) -> new Router()
