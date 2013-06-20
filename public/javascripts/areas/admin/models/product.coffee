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
        [{pattern:'digits', msg: 'A altura deve ser um número.'}
         {required: false}]
      shippingWidth:
        [{pattern:'digits', msg: 'A largura deve ser um número.'}
         {required: false}]
      shippingDepth:
        [{pattern:'digits', msg: 'A profundidade deve ser um número.'}
         {required: false}]
      shippingWeight:
        [{pattern:'digits', msg: 'O peso deve ser um número.'}
         {required: false}]
      inventory:
        [{pattern:'digits', msg: 'O estoque deve ser um número.'}
        {required: false}]
