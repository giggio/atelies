define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/account.html'
], ($, Backbone, Handlebars, accountTemplate) ->
  class AccountView extends Backbone.Open.View
    template: accountTemplate
    events:
      'click #resendConfirmationEmail':'_resendConfirmationEmail'
    initialize: (opt) ->
      @user = opt.user
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      @$el.html context user: @user
    _resendConfirmationEmail: (e)->
      e.preventDefault()
      @showDialog "<strong>E-mail enviado com sucesso.</strong>
        Verifique sua caixa de mensagens, e caso não o encontre verifique também a caixa de spam.
        Adicione contato@atelies.com.br como um contato confiável no seu sistema de e-mails.<br /><br />
        Usamos um sistema de envio de e-mails muito rápido, você deve recebê-lo em poucos minutos, senão imediatamente.
        Se não receber solicite o e-mail novamente.
        Se não receber entre em contato com contato@atelies.com.br para que possamos auxiliá-lo.", "E-mail enviado"
