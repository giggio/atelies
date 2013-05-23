define [
  'backbone'
  'epoxy'
], (Backbone) ->
  class OpenView extends Backbone.Epoxy.View
    initializeBindings: (extension = {}) ->
      bindings = {}
      elsWithAttribute = $("input[id][type!='button'],textarea[id]", @el)
      for el in elsWithAttribute
        name = $(el).attr 'id'
        bindings["##{name}"] = "value:#{name}"
      $.extend true, bindings, extension
