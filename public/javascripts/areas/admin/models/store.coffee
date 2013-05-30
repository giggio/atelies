define [
  'backbone'
], (Backbone) ->
  class Product extends Backbone.Open.Model
    defaults:
      _id:undefined
      name:undefined
      email:undefined
      description:undefined
      city:undefined
      state:'SP'
      otherUrl:undefined
      banner:undefined
      flyer:undefined
      phoneNumber:undefined
    validation:
      name:
        required: true
        msg: 'Informe o nome da loja.'
      email:
        [{pattern:'email', msg:'O e-mail deve ser válido.'}
        {required: false}]
      city:
        required: true
        msg: 'Informe a cidade.'
      otherUrl:
        [{pattern:'url', msg:'Informe um link válido para o outro site, começando com http ou https.'}
        {required: false}]
      banner:
        [{pattern:'url', msg:"Informe um link válido para o banner, começando com http ou https."}
        {required: false}]
      flyer:
        [{pattern:'url', msg:"Informe um link válido para o flyer, começando com http ou https."}
        {required: false}]
