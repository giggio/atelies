define [
  'backbone'
  'jqform'
], (Backbone) ->
  class Store extends Backbone.Open.Model
    sync: (method, model, opt) ->
      return Backbone.sync.apply @, arguments unless @hasFiles
      methodMap = create:'POST', update:'PUT', patch:'PATCH', delete:'DELETE', read:'GET'
      type = methodMap[method]
      options = type: type, url: @url()
      options.success = (data, code, xhr) =>
        opt.success data if opt.success?
      options.error = (xhr, error, type) ->
        opt.error error if opt.error?
      @form.ajaxSubmit options
    initialize: ->
      @bind 'change:autoCalculateShipping', @_autoCalculateShippingChanged
      @bind 'change:pagseguro', @_pagseguroChanged
    _pagseguroChanged: ->
      @set 'autoCalculateShipping', true if @get 'pagseguro'
    _autoCalculateShippingChanged: ->
      @set('pagseguro', false) unless @get 'autoCalculateShipping'
    defaults:
      _id:undefined
      name:undefined
      email:undefined
      description:undefined
      homePageDescription:undefined
      homePageImage:undefined
      urlFacebook:undefined
      urlTwitter:undefined
      city:undefined
      state:'SP'
      zip:undefined
      otherUrl:undefined
      banner:undefined
      flyer:undefined
      phoneNumber:undefined
      autoCalculateShipping:true
      pagseguro:true
      pagseguroEmail:undefined
      pagseguroToken:undefined
    validation:
      name:
        required: true
        msg: 'Informe o nome da loja.'
      email:
        [{pattern:'email', msg:'O e-mail deve ser válido.'}
        {required: false}]
      city:
        required: true
        msg: 'Informe a cidade.'
      zip:
        zip: true
        msg:'Informe o CEP no formato 99999-999.'
      otherUrl:
        [{pattern:'url', msg:'Informe um link válido para o outro site, começando com http ou https.'}
         {required: false}]
      pagseguroEmail:
        [{required: true, msg:'O e-mail é obrigatório.'}
         {pattern:'email', msg:'O e-mail deve ser válido.'}]
      pagseguroToken:
        [{required: true, msg:'O token do PagSeguro é obrigatório.'}
         {length: 32, msg: 'O token do PagSeguro deve possuir 32 caracteres.'}]
