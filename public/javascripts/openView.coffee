define [
  'backbone'
  'handlebars'
  'areas/shared/views/dialog'
  'epoxy'
], (Backbone, Handlebars, Dialog) ->
  class OpenView extends Backbone.Epoxy.View
    initializeBindings: (extension = {}) ->
      bindings = {}
      for el in $("input[id][type!='button'][type!='checkbox'][type!='file'],textarea[id],select[id]", @el)
        name = $(el).attr 'id'
        bindings["##{name}"] = "value:#{name}"
      $.extend true, bindings, extension
    showDialog: (title, message, modalId, closeMsg) ->
      Dialog.show @$el, title, message, modalId, closeMsg
