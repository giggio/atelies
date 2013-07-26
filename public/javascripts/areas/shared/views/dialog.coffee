define [
  'backbone'
  'handlebars'
  'text!./templates/dialog.html'
], (Backbone, Handlebars, dialogTemplate) ->
  class DialogView extends Backbone.View
    dialogTemplate: dialogTemplate
    initialize: (opt) ->
      @title = opt.title
      @message = opt.message
      @modalId = opt.modalId or "dialog#{Math.random() * Math.pow(10, 18)}"
      @closeMsg = opt.closeMsg or 'Fechar'
    render: ->
      context = Handlebars.compile @dialogTemplate
      @$el.html context title: @title, message: @message, modalId: @modalId, closeMsg: @closeMsg
      $("##{@modalId}", @$el).modal()
    @show: (el, title, message, modalId, closeMsg) ->
      if typeof title is 'object'
        [opt, title, message, modalId, closeMsg]=[title, opt.title, opt.message, opt.modalId, opt.closeMsg]
      dialog = new DialogView title: title, message: message, modalId: modalId, closeMsg: closeMsg
      el.append dialog.$el
      dialog.render()
