define [
  'jquery'
  'underscore'
  'backboneValidation'
  './openModel'
  './openView'
  './openRouter'
  './openRoutes'
  './converters'
  'twitterBootstrap'
  'epoxy'
], ($, _, Validation, OpenModel, OpenView, OpenRouter, OpenRoutes, converters) ->
  Validation.configure forceUpdate: true
  _.extend Validation.callbacks,
    valid: (view, attr, selector) ->
      control = view.$('[' + selector + '=' + attr + ']')
      group = control.parents(".control-group")
      group.removeClass("error")
  
      switch control.data("error-style")
        when "tooltip"
          control.tooltip "destroy"
        when "inline"
          group.find(".help-inline.error-message").remove()
        else
          group.find(".help-block.error-message").remove()
  
    invalid: (view, attr, error, selector) ->
      control = view.$('[' + selector + '=' + attr + ']')
      group = control.parents(".control-group")
      group.addClass("error")
  
      switch control.data("error-style")
        when "tooltip"
          return if control.data("tooltip")?.options?.title is error
          control.tooltip "destroy"
          position = control.data("tooltip-position") || "right"
          control.tooltip
            placement: position
            trigger: "manual"
            title: error
          control.tooltip "show"
        when "inline"
          if group.find(".help-inline").length == 0
            group.find(".controls").append("<span class=\"help-inline error-message\"></span>")
          target = group.find(".help-inline")
          target.text(error)
        else
          if group.find(".help-block").length == 0
            group.find(".controls").append("<p class=\"help-block error-message\"></p>")
          target = group.find(".help-block")
          target.text(error)
  Backbone.Open = {}
  Backbone.Open.Model = OpenModel
  Backbone.Open.View = OpenView
  Backbone.Open.Router = OpenRouter
  Backbone.Open.Routes = OpenRoutes
  Backbone.Epoxy.binding.addFilter 'integerOr', (val) -> if $.isNumeric val then parseInt val else val
  Backbone.Epoxy.binding.addFilter 'decimalOr', (val) -> if $.isNumeric val then parseFloat val else val
  Backbone.Epoxy.binding.addFilter 'currency', converters.currency
  Backbone.View::render = ->
  Backbone.View::close = ->
    try
      @remove()
      @off()
      @stopListening()
    catch error
  _.extend Backbone.Validation.validators,
    zip: (value, attr, customValue, model) ->
      unless /^\d{5}-\d{3}$/.test value
        return "CEP inválido."
      return undefined
    regex: (value, attr, customValue, model) ->
      r = new RegExp customValue
      r.test value
  return Backbone
