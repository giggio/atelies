define [
  'backbone'
  'handlebars'
  'text!./areas/shared/views/templates/dialog.html'
  'epoxy'
], (Backbone, Handlebars, dialogTemplate) ->
  class OpenView extends Backbone.Epoxy.View
    dialogTemplate: dialogTemplate
    initializeBindings: (extension = {}) ->
      bindings = {}
      for el in $("input[id][type!='button'][type!='checkbox'][type!='file'],textarea[id],select[id]", @el)
        name = $(el).attr 'id'
        bindings["##{name}"] = "value:#{name}"
      $.extend true, bindings, extension
    showDialog: (title, message, modalId = "dialog#{Math.random() * Math.pow(10, 18)}", closeMsg = 'Fechar') ->
      context = Handlebars.compile @dialogTemplate
      @$el.append context title: title, message: message, modalId: modalId, closeMsg: closeMsg
      $("##{modalId}", @$el).modal()
