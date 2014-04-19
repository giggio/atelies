define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/finishOrderOrderNotCompleted.html'
], ($, Backbone, Handlebars, finishOrderOrderNotCompletedTemplate) ->
  class FinishOrderOrderNotCompletedView extends Backbone.Open.View
    events:
      'click #backToStore': -> Backbone.history.navigate 'home', true
    template: finishOrderOrderNotCompletedTemplate
    render: =>
      context = Handlebars.compile @template
      @$el.html context()
