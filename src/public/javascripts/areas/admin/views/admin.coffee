define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/admin.html'
], ($, Backbone, Handlebars, adminTemplate) ->
  class Admin extends Backbone.View
    template: adminTemplate
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context()
