define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/siteAdmin.html'
], ($, Backbone, Handlebars, siteAdminTemplate) ->
  class AdminView extends Backbone.Open.View
    template: siteAdminTemplate
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context()
      super
