define [
  'backboneConfig'
], (Backbone) ->
  class Evaluation extends Backbone.Open.Model
    idAttribute: "_id"
    validation:
      rating:
        required: true, msg: 'O número de estrelas é obrigatório.'
