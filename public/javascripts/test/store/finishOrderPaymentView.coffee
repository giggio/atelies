define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/finishOrderPayment'
  'areas/store/models/cart'
  '../support/_specHelper'
], ($, FinishOrderPaymentView, Cart) ->
  product1  = generatorc.product.a()
  product2  = generatorc.product.b()
  store1    = generatorc.store.a()
  view = deliveryAddress = null
  el = $('<div></div>')
  describe 'FinishOrderPaymentView', ->
    describe 'One item cart with quantity two', ->
      before ->
        cart = Cart.get(store1.slug)
        cart.clear()
        item = _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 1234567.1
        item2 = _id: '2', name: 'produto 2', quantity: 2, picture: 'http://someurl2.com', url: 'store_1#prod_2', price: 1
        cart.addItem item
        cart.addItem item2
        deliveryAddress = street: 'Rua A', street2: 'Bairro', city: 'Cidade', state: 'PA', zip: '98741-789'
        user = name: 'Joao Silva', deliveryAddress: deliveryAddress, phoneNumber: '4654456454'
        view = new FinishOrderPaymentView el:el, store: store1, user: user, cart: cart
        view.render()
      it 'shows the sales summary', ->
        $("#shippingCost", el).text().should.equal 'R$ 1,00'
        $("#productsInfo", el).text().should.equal '2 produtos'
        $("#totalProductsPrice", el).text().should.equal 'R$ 1.234.568,10'
        $("#totalSaleAmount", el).text().should.equal 'R$ 1.234.569,10'
      it 'shows the delivery address', ->
        $("#street", el).text().should.equal deliveryAddress.street
        $("#street2", el).text().should.equal deliveryAddress.street2
        $("#city", el).text().should.equal deliveryAddress.city
        $("#state", el).text().should.equal deliveryAddress.state
        $("#zip", el).text().should.equal deliveryAddress.zip
