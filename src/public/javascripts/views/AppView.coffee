define [
  'jquery'
  'Backbone'
  'Handlebars'
  'text!views/templates/AppTemplate.html'
], ($, Backbone, Handlebars, appTemplate) ->
  class AppView extends Backbone.View
    template: appTemplate
    render: ->
      @$el.html Handlebars.compile @template
