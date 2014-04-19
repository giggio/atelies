define [
  'backboneConfig'
], (Backbone) ->
  class StorePaypal extends Backbone.Open.Model
    defaults:
      paypalClientId:undefined
      paypalSecret:undefined
    validation:
      paypalClientId:
        required:true
        msg:'O id do cliente do Paypal deve ser informado.'
      paypalSecret:
        required:true
        msg: 'O segredo do Paypal é obrigatório.'
