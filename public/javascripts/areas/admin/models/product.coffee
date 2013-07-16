define [
  'backbone'
  'jqform'
], (Backbone) ->
  class Product extends Backbone.Open.Model
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
    defaults:
      _id:undefined
      slug:undefined
      name:undefined
      description:undefined
      tags:undefined
      price:undefined
      #picture:undefined
      height:undefined
      width:undefined
      depth:undefined
      weight:undefined
      shippingHeight:undefined
      shippingWidth:undefined
      shippingDepth:undefined
      shippingWeight:undefined
      inventory:undefined
      hasInventory:true
    validation:
      name:
        required:true
        msg: 'O nome é obrigatório.'
      price:
        [{required: true, msg: 'O preço é obrigatório.'}
         {pattern:'number', msg: 'O preço deve ser um número.'}]
      #picture:
        #[{pattern:'url', msg: 'A imagem deve ser uma url.'}
         #{required: false}]
      height:
        [{pattern:'digits', msg: 'A altura deve ser um número.'}
         {required: false}]
      width:
        [{pattern:'digits', msg: 'A largura deve ser um número.'}
         {required: false}]
      depth:
        [{pattern:'digits', msg: 'A profundidade deve ser um número.'}
         {required: false}]
      weight:
        [{pattern:'digits', msg: 'O peso deve ser um número.'}
         {required: false}]
      shippingHeight:
        [{required: true, msg: 'A altura de postagem é obrigatória.'}
         {range:[2,105], msg: 'A altura deve ser um número entre 2 e 105.'}]
      shippingWidth:
        [{required: true, msg: 'A largura de postagem é obrigatória.'}
         {range:[11,105], msg: 'A largura deve ser um número entre 11 e 105.'}]
      shippingDepth:
        [{required: true, msg: 'A profundidade de postagem é obrigatória.'}
         {range:[16,105], msg: 'A profundidade deve ser um número entre 16 e 105.'}]
      shippingWeight:
        [{required: true, msg: 'O peso de postagem é obrigatório.'}
         {range:[0,30], msg: 'O peso deve ser um número entre 0 e 30.'}]
      inventory:
        [{pattern:'digits', msg: 'O estoque deve ser um número.'}
        {required: false}]
