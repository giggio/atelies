define [
  'backbone'
], (Backbone) ->
  class CartItem extends Backbone.Open.Model
    idAttribute: "_id"
    validation:
      quantity:
        pattern:'digits', msg: 'A quantidade deve ser um número.'
    defaults:
      picture: 'http://dummyimage.com/150x150/000/fff&text=%3F'
