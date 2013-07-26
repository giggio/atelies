define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/finishOrderOrderFinished.html'
], ($, Backbone, Handlebars, finishOrderOrderFinishedTemplate) ->
  class FinishOrderOrderFinishedView extends Backbone.Open.View
    template: finishOrderOrderFinishedTemplate
    render: =>
      context = Handlebars.compile @template
      @$el.html context()
