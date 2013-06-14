define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/finishOrderOrderFinished.html'
], ($, Backbone, Handlebars, finishOrderOrderFinishedTemplate) ->
  class FinishOrderOrderFinishedView extends Backbone.View
    template: finishOrderOrderFinishedTemplate
    render: =>
      context = Handlebars.compile @template
      @$el.html context()
