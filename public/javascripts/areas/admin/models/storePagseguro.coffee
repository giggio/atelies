define [
  'backboneConfig'
], (Backbone) ->
  class StorePagseguro extends Backbone.Open.Model
    defaults:
      pagseguroEmail:undefined
      pagseguroToken:undefined
    validation:
      pagseguroEmail:
        pattern:'email'
        msg:'O e-mail deve existir e ser válido.'
      pagseguroToken:
        length: 32
        msg: 'O token do PagSeguro é obrigatório e deve possuir 32 caracteres.'
