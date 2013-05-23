define [
  'backbone'
], (Backbone) ->
  class CartItem extends Backbone.Open.Model
    idAttribute: "_id"
    validation:
      quantity:
        pattern:'digits', msg: 'A quantidade deve ser um número.'
