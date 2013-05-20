define [
  'backbone'
], (Backbone) ->
  class Product extends Backbone.Model
    idAttribute: "_id"
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
      inventory:
        [{pattern:'digits', msg: 'O estoque deve ser um número.'}
        {required: false}]
