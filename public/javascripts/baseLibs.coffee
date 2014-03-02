define [
  'jquery'
  './errorLogger'
  './logger'
  'handlebars'
  'swag'
  './backboneConfig'
  './loginPopover'
  './jqueryValidationExt'
  'jqexpander'
  'jrating'
], ($, ErrorLogger, Logger, Handlebars, Swag) ->
  Swag.registerHelpers Handlebars
  $ ->
    logger = new Logger()
    $('.expander .answer').expander
      slicePoint: 160
      expandText: 'ler mais'
      userCollapseText: 'ler menos'
    $(document).ajaxSend (e, xhr, settings) ->
      $("#overlay").show() if settings.type isnt 'GET'
    $(document ).ajaxStop ->
      $("#overlay").hide()
    $(document).ajaxError (e, xhr, opt, exception) ->
      return if opt.url is '/api/error'
      ErrorLogger.logError 'ajax', exception, opt.url, opt.type
      logger.log category: 'error', action: "#{opt.type} #{opt.url}", label: "ajax #{exception}", field: page: window?.location?.pathname
