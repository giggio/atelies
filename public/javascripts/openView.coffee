define [
  'backbone'
  'epoxy'
], (Backbone) ->
  class OpenView extends Backbone.Epoxy.View
    initializeBindings: (extension = {}) ->
      bindings = {}
      for el in $("input[id][type!='button'][type!='checkbox'][type!='file'],textarea[id],select[id]", @el)
        name = $(el).attr 'id'
        bindings["##{name}"] = "value:#{name}"
      $.extend true, bindings, extension
