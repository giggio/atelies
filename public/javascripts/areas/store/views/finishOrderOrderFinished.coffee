define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/finishOrderOrderFinished.html'
], ($, Backbone, Handlebars, finishOrderOrderFinishedTemplate) ->
  class FinishOrderOrderFinishedView extends Backbone.Open.View
    events:
      'click #backToStore': -> Backbone.history.navigate('home', true)
    template: finishOrderOrderFinishedTemplate
    render: =>
      context = Handlebars.compile @template
      @$el.html context()
      super
