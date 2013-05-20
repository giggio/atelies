define [
  'underscore'
  'backboneModelBinder'
  'backboneValidation'
  'twitterBootstrap'
], (_, ModelBinder, Validation) ->
  ModelBinder.SetOptions modelSetOptions: validate: true
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
