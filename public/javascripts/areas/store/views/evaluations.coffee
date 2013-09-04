define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'showdown'
  'md5'
  'text!./templates/evaluations.html'
], ($, _, Backbone, Handlebars, Showdown, md5, evaluationsTemplate) ->
  class EvaluationsView extends Backbone.Open.View
    template: evaluationsTemplate
    initialize: (opt) =>
      @markdown = new Showdown.converter()
      @store = opt.store
      @evaluations = opt.evaluations
      for e in @evaluations
        e.niceDate = @createNiceDate e.date
        e.gravatarUrl = "https://secure.gravatar.com/avatar/#{md5(e.userEmail.toLowerCase())}?d=mm&r=pg&s=50"
        e.formattedBody = @markdown.makeHtml e.body
      context = Handlebars.compile @template
      @$el.html context store: @store, evaluations: @evaluations, hasEvaluations: @evaluations.length > 0
      @$(".ratingStars").jRating
        bigStarsPath : "#{staticPath}/images/jrating/stars.png"
        smallStarsPath : "#{staticPath}/images/jrating/small.png"
        rateMax: 5
        isDisabled: on
    createNiceDate: (date) ->
      date = new Date(date) if typeof date is 'string'
      date = date.getTime() unless typeof date is 'number'
      diffInMils = new Date().getTime() - date
      diffInMins = diffInMils / 1000 / 60
      diffInHours = diffInMins / 60
      diffInDays = diffInHours / 24
      switch
        when diffInMins < 0 then 'no futuro'
        when diffInMins < 1 then 'agorinha'
        when diffInMins < 2 then 'a um minuto'
        when diffInMins < 16 then 'a quinze minutos'
        when diffInMins < 45 then 'a meia hora'
        when diffInMins < 75 then 'a uma hora'
        when diffInMins < 140 then 'a duas horas'
        when diffInHours < 24 then "a #{Math.floor diffInHours, 0} horas"
        else "a #{Math.floor diffInDays, 0} dias"
