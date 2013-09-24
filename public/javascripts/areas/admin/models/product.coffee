define [
  'underscore'
  'backboneConfig'
  'jqform'
], (_, Backbone) ->
  class Product extends Backbone.Open.Model
    initialize: ->
      @bind 'change:hasInventory', @_hasInventoryChanged
      @bind 'change:shippingApplies', @_shippingAppliesChanged
    _shippingAppliesChanged: ->
      if @get 'shippingApplies'
        @requireShippingInfo()
      else
        @doNotRequireShippingInfo()
      @validate()
    _hasInventoryChanged: ->
      @validation.inventory[0].required = @get 'hasInventory'
      @validate() if @validate?
    sync: (method, model, opt) ->
      return Backbone.sync.apply @, arguments unless @hasFiles
      methodMap = create:'POST', update:'PUT', patch:'PATCH', delete:'DELETE', read:'GET'
      type = methodMap[method]
      options = type: type, url: @url()
      options.success = (data, code, xhr) =>
        opt.success data if opt.success?
      options.error = (xhr, error, type) ->
        opt.error xhr if opt.error?
      @form.ajaxSubmit options
    _doNotRequireShippingInfo: false
    _storeDoesNotRequireShippingInfo: false
    storeDoesNotRequireShippingInfo: -> @_storeDoesNotRequireShippingInfo = true
    doNotRequireShippingInfo: -> @_doNotRequireShippingInfo = true
    requireShippingInfo: -> @_doNotRequireShippingInfo = false
    defaults:
      _id:undefined
      slug:undefined
      name:undefined
      description:undefined
      tags:undefined
      categories:undefined
      price:undefined
      picture:undefined
      height:undefined
      width:undefined
      depth:undefined
      weight:undefined
      shippingApplies:true
      shippingCharge:true
      shippingHeight:undefined
      shippingWidth:undefined
      shippingDepth:undefined
      shippingWeight:undefined
      inventory:undefined
      hasInventory:false
    validation:
      name:
        required:true
        msg: 'O nome é obrigatório.'
      price:
        [{required: true, msg: 'O preço é obrigatório.'}
         {pattern:'number', msg: 'O preço deve ser um número.'}]
      height:
        [{pattern:'number', msg: 'A altura deve ser um número.'}
         {required: false}]
      width:
        [{pattern:'number', msg: 'A largura deve ser um número.'}
         {required: false}]
      depth:
        [{pattern:'number', msg: 'A profundidade deve ser um número.'}
         {required: false}]
      weight:
        [{pattern:'number', msg: 'O peso deve ser um número.'}
         {required: false}]
      shippingHeight:
        [{ msg: 'A altura de postagem é obrigatória.', required: -> !@_doNotRequireShippingInfo and !@_storeDoesNotRequireShippingInfo },
         {range:[2,105], msg: 'A altura deve ser um número entre 2 e 105.'}]
      shippingWidth:
        [{msg: 'A largura de postagem é obrigatória.', required: -> !@_doNotRequireShippingInfo and !@_storeDoesNotRequireShippingInfo }
         {range:[11,105], msg: 'A largura deve ser um número entre 11 e 105.'}]
      shippingDepth:
        [{msg: 'A profundidade de postagem é obrigatória.', required: -> !@_doNotRequireShippingInfo and !@_storeDoesNotRequireShippingInfo }
         {range:[16,105], msg: 'A profundidade deve ser um número entre 16 e 105.'}]
      shippingWeight:
        [{msg: 'O peso de postagem é obrigatório.', required: -> !@_doNotRequireShippingInfo and !@_storeDoesNotRequireShippingInfo }
         {range:[0,30], msg: 'O peso deve ser um número entre 0 e 30.'}]
      inventory:
        [{required: false, msg: 'O estoque é obrigatório quando o produto terá estoque.' }
         {pattern:'digits', msg: 'O estoque deve ser um número.'}]
