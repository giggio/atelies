define [
  'jquery'
  'Backbone'
  'Handlebars'
  'text!views/templates/HomeTemplate.html'
], ($, Backbone, Handlebars, homeTemplate) ->
  class Home extends Backbone.View
    template: homeTemplate
    render: ->
      @$el.empty()
      @$el.html Handlebars.compile @template
