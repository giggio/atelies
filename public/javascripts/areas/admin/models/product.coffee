define [
  'backbone'
], (Backbone) ->
  class Product extends Backbone.Open.Model
    defaults:
      _id:undefined
      slug:undefined
      name:undefined
      description:undefined
      tags:undefined
      price:undefined
      picture:undefined
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
      picture:
        [{pattern:'url', msg: 'A imagem deve ser uma url.'}
         {required: false}]
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
         {pattern:'digits', msg: 'A altura deve ser um número.'}]
      shippingWidth:
        [{required: true, msg: 'A largura de postagem é obrigatória.'}
         {pattern:'digits', msg: 'A largura deve ser um número.'}]
      shippingDepth:
        [{required: true, msg: 'A profundidade de postagem é obrigatória.'}
         {pattern:'digits', msg: 'A profundidade deve ser um número.'}]
      shippingWeight:
        [{required: true, msg: 'O peso de postagem é obrigatório.'}
         {pattern:'digits', msg: 'O peso deve ser um número.'}]
      inventory:
        [{pattern:'digits', msg: 'O estoque deve ser um número.'}
        {required: false}]
