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
        pattern:'url'
        required: false
      height:
        pattern:'digits'
        required: false
      width:
        pattern:'digits'
        required: false
      depth:
        pattern:'digits'
        required: false
      weight:
        pattern:'digits'
        required: false
      inventory:
        pattern:'digits'
        required: false
