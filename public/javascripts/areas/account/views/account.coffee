define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/account.html'
], ($, Backbone, Handlebars, accountTemplate) ->
  class AccountView extends Backbone.Open.View
    template: accountTemplate
    initialize: (opt) ->
      @user = opt.user
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context user: @user
