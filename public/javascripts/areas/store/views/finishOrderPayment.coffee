define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/products'
  '../models/cart'
  '../models/orders'
  'text!./templates/finishOrderPayment.html'
  './cartItem'
  '../../../converters'
], ($, _, Backbone, Handlebars, Products, Cart, Orders, finishOrderPaymentTemplate, CartItemView, converters) ->
  class FinishOrderPayment extends Backbone.Open.View
    events:
      'click #selectPaymentType':'_selectPaymentType'
      'click #backToStore': -> Backbone.history.navigate('', true)
      'click #goBackToCart': -> Backbone.history.navigate('cart', true)
      'click #goBackToShipping': -> Backbone.history.navigate('finishOrder/shipping', true)
    template: finishOrderPaymentTemplate
    initialize: (opt) =>
      @store = opt.store
      @cart = opt.cart
      @user = opt.user
    render: =>
      context = Handlebars.compile @template
      @$el.html context pagseguro:@store.pagseguro, hasShipping: @cart.hasShipping()
      super
    _selectPaymentType: ->
      selected = $('#paymentTypesHolder input[type=radio]:checked', @$el)
      paymentType = switch selected.val()
        when "pagseguro" then type:'pagseguro', name:'PagSeguro'
        when "directSell" then type:'directSell', name:'Pagamento direto ao fornecedor'
      @cart.choosePaymentType paymentType
      Backbone.history.navigate 'finishOrder/summary', trigger: true
