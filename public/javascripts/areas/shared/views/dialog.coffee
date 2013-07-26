define [
  'backbone'
  'handlebars'
  'text!./templates/dialog.html'
], (Backbone, Handlebars, dialogTemplate) ->
  class DialogView extends Backbone.View
    dialogTemplate: dialogTemplate
    initialize: (opt) ->
      @message = opt.message
      @title = opt.title or "Ateliês"
      @modalId = opt.modalId or "dialog#{Math.random() * Math.pow(10, 18)}"
      @closeMsg = opt.closeMsg or 'Fechar'
    render: ->
      context = Handlebars.compile @dialogTemplate
      @$el.html context title: @title, message: @message, modalId: @modalId, closeMsg: @closeMsg
      $("##{@modalId}", @$el).modal()
    @show: (el, message, title, modalId, closeMsg) ->
      if typeof message is 'object'
        [opt, title, message, modalId, closeMsg]=[title, opt.title, opt.message, opt.modalId, opt.closeMsg]
      dialog = new DialogView message: message, title: title, modalId: modalId, closeMsg: closeMsg
      el.append dialog.$el
      dialog.render()
    @showError: (el, message, modalId, closeMsg) ->
      title = "Um erro ocorreu"
      DialogView.show el, message, title, modalId, closeMsg
