define [
  'backbone'
  'handlebars'
  'areas/shared/views/dialog'
  'epoxy'
], (Backbone, Handlebars, Dialog) ->
  class OpenView extends Backbone.Epoxy.View
    constructor: (opt) ->
      @staticPath = if opt?.staticPath? then opt.staticPath else staticPath
      Backbone.Epoxy.View.apply @, arguments
    initializeBindings: (extension = {}) ->
      bindings = {}
      for el in $("input[id][type!='button'][type!='checkbox'][type!='file'],textarea[id],select[id]", @el)
        name = $(el).attr 'id'
        bindings["##{name}"] = "value:#{name}"
      $.extend true, bindings, extension
    showDialog: (message, title, modalId, closeMsg) ->
      Dialog.show @$el, message, title, modalId, closeMsg
    showDialogError: (message, modalId, closeMsg) ->
      Dialog.showError @$el, message, modalId, closeMsg
