define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/finishOrderSummary'
  'areas/store/models/cart'
], ($, FinishOrderSummaryView, Cart) ->
  product1  = generatorc.product.a()
  product2  = generatorc.product.b()
  store1    = generatorc.store.a()
  store2    = generatorc.store.b()
  product3  = generatorc.product.c()
  view = deliveryAddress = null
  el = $('<div></div>')
  describe 'FinishOrderSummaryView', ->
    describe 'Showing order to be finished', ->
      after -> view.close()
      before ->
        Cart.clear()
        cart = Cart.get(store1.slug)
        item = _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 1234567.1, shippingApplies: true
        item2 = _id: '2', name: 'produto 2', quantity: 2, picture: 'http://someurl2.com', url: 'store_1#prod_2', price: 1, shippingApplies: true
        cart.addItem item
        cart.addItem item2
        cart.setShippingOptions [
          { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
          { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
        ]
        cart.chooseShippingOption 'pac'
        cart.choosePaymentType type:'pagseguro', name:"PagSeguro"
        deliveryAddress = street: 'Rua A', street2: 'Bairro', city: 'Cidade', state: 'PA', zip: '98741-789'
        user = name: 'Joao Silva', deliveryAddress: deliveryAddress, phoneNumber: '4654456454'
        view = new FinishOrderSummaryView el:el, store: store1, user: user, cart: cart
        view.render()
      it 'shows the sales summary', ->
        $("#shippingCost", el).text().should.equal 'R$ 3,33'
        $("#productsInfo", el).text().should.equal '2 produtos'
        $("#totalProductsPrice", el).text().should.equal 'R$ 1.234.568,10'
        $("#totalSaleAmount", el).text().should.equal 'R$ 1.234.571,43'
      it 'shows the delivery address', ->
        $("#street", el).text().should.equal deliveryAddress.street
        $("#street2", el).text().should.equal deliveryAddress.street2
        $("#city", el).text().should.equal deliveryAddress.city
        $("#state", el).text().should.equal deliveryAddress.state
        $("#zip", el).text().should.equal deliveryAddress.zip
      it 'shows the payment type', ->
        $("#paymentType", el).text().should.equal "PagSeguro"

    describe 'Showing order to be finished with products that have no shipping', ->
      after -> view.close()
      before ->
        Cart.clear()
        cart = Cart.get(store2.slug)
        item = _id: '1', name: 'produto 1', picture: 'http://someurl.com', url: 'store_2#prod_1', price: 2, shippingApplies: false
        item2 = _id: '2', name: 'produto 2', picture: 'http://someurl2.com', url: 'store_2#prod_2', price: 4, shippingApplies: false
        cart.addItem item
        cart.addItem item2
        cart.addItem item2
        cart.choosePaymentType type:'directSell', name:'Pagamento direto ao fornecedor'
        deliveryAddress = street: 'Rua A', street2: 'Bairro', city: 'Cidade', state: 'PA', zip: '98741-789'
        user = name: 'Joao Silva', deliveryAddress: deliveryAddress, phoneNumber: '4654456454'
        view = new FinishOrderSummaryView el:el, store: store1, user: user, cart: cart
        view.render()
      it 'shows the sales summary', ->
        $("#shippingCost", el).text().should.equal 'R$ 0,00'
        $("#productsInfo", el).text().should.equal '2 produtos'
        $("#totalProductsPrice", el).text().should.equal 'R$ 10,00'
        $("#totalSaleAmount", el).text().should.equal 'R$ 10,00'
      it 'shows no shipping information', ->
        $("#shipping p", el).text().trim().should.equal 'Nenhum produto será postado'

    describe 'Finishing order with pagseguro', ->
      item = item2 = ajaxSpy = historySpy = dataPosted = orderPosted = null
      after -> view.close()
      before ->
        Cart.clear()
        cart = Cart.get(store1.slug)
        item = _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 1234567.1, shippingApplies: true
        item2 = _id: '2', name: 'produto 2', quantity: 2, picture: 'http://someurl2.com', url: 'store_1#prod_2', price: 1, shippingApplies: true
        cart.addItem item
        cart.addItem item2
        cart.setShippingOptions [
          { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
          { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
        ]
        cart.chooseShippingOption 'pac'
        cart.choosePaymentType type:'pagseguro', name:'PagSeguro'
        deliveryAddress = street: 'Rua A', street2: 'Bairro', city: 'Cidade', state: 'PA', zip: '98741-789'
        user = name: 'Joao Silva', deliveryAddress: deliveryAddress, phoneNumber: '4654456454'
        view = new FinishOrderSummaryView el:el, store: store1, user: user, cart: cart
        ajaxSpy = sinon.stub $, 'ajax', (opt) =>
          dataPosted = opt
          orderPosted = JSON.parse opt.data
          opt.success redirect: 'http://pagsegurourl', order:_id: '1456'
        historySpy = sinon.spy Backbone.history, "navigate"
        view.render()
        $("#finishOrder", el).click()
      after ->
        ajaxSpy.restore()
        historySpy.restore()
      it 'has sent the order to the server', ->
        dataPosted.url.should.equal "/api/orders/#{store1._id}"
        dataPosted.type.should.equal "POST"
      it 'posted the correct order', ->
        orderPosted.paymentType.should.equal 'pagseguro'
        items = orderPosted.items
        items.length.should.equal 2
        postedItem1 = items[0]
        postedItem2 = items[1]
        postedItem1._id.should.equal item._id
        postedItem1.quantity.should.equal item.quantity
        postedItem2._id.should.equal item2._id
        postedItem2.quantity.should.equal item2.quantity
      #it 'has redirected the user to the order finished route', ->
        #historySpy.should.have.been.calledWith "finishOrder/orderFinished", trigger:true
      it 'has redirected the user to pagseguro', ->
        window.location.should.equal 'http://pagsegurourl'
      it 'cleared the cart', ->
        cart = Cart.get store1.slug
        cart.items().length.should.equal 0

    describe 'Finishing order without pagseguro', ->
      item = item2 = ajaxSpy = historySpy = dataPosted = orderPosted = null
      after -> view.close()
      before ->
        Cart.clear()
        cart = Cart.get(store2.slug)
        item = _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_2#prod_1', price: 1234567.1, shippingApplies: true
        item2 = _id: '2', name: 'produto 2', quantity: 2, picture: 'http://someurl2.com', url: 'store_2#prod_2', price: 1, shippingApplies: true
        cart.addItem item
        cart.addItem item2
        cart.setShippingOptions [
          { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
          { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
        ]
        cart.chooseShippingOption 'pac'
        cart.choosePaymentType type:'directSell', name:'Pagamento direto ao fornecedor'
        deliveryAddress = street: 'Rua A', street2: 'Bairro', city: 'Cidade', state: 'PA', zip: '98741-789'
        user = name: 'Joao Silva', deliveryAddress: deliveryAddress, phoneNumber: '4654456454'
        view = new FinishOrderSummaryView el:el, store: store2, user: user, cart: cart
        ajaxSpy = sinon.stub $, 'ajax', (opt) =>
          dataPosted = opt
          orderPosted = JSON.parse opt.data
          opt.success _id: '1456'
        historySpy = sinon.spy Backbone.history, "navigate"
        view.render()
        $("#finishOrder", el).click()
      after ->
        ajaxSpy.restore()
        historySpy.restore()
      it 'has sent the order to the server', ->
        dataPosted.url.should.equal "/api/orders/#{store2._id}"
        dataPosted.type.should.equal "POST"
      it 'posted the correct order', ->
        orderPosted.paymentType.should.equal 'directSell'
        items = orderPosted.items
        items.length.should.equal 2
        postedItem1 = items[0]
        postedItem2 = items[1]
        postedItem1._id.should.equal item._id
        postedItem1.quantity.should.equal item.quantity
        postedItem2._id.should.equal item2._id
        postedItem2.quantity.should.equal item2.quantity
      it 'has redirected the user to the order finished route', ->
        historySpy.should.have.been.calledWith "finishOrder/orderFinished", trigger:true
      it 'cleared the cart', ->
        cart = Cart.get store2.slug
        cart.items().length.should.equal 0

    describe 'Finishing order with server error', ->
      item = item2 = ajaxSpy = historySpy = dataPosted = orderPosted = null
      after -> view.close()
      before ->
        Cart.clear()
        cart = Cart.get(store1.slug)
        item = _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 1234567.1, shippingApplies: true
        item2 = _id: '2', name: 'produto 2', quantity: 2, picture: 'http://someurl2.com', url: 'store_1#prod_2', price: 1, shippingApplies: true
        cart.addItem item
        cart.addItem item2
        cart.setShippingOptions [
          { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
          { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
        ]
        cart.chooseShippingOption 'pac'
        cart.choosePaymentType type:'pagseguro', name:'PagSeguro'
        deliveryAddress = street: 'Rua A', street2: 'Bairro', city: 'Cidade', state: 'PA', zip: '98741-789'
        user = name: 'Joao Silva', deliveryAddress: deliveryAddress, phoneNumber: '4654456454'
        view = new FinishOrderSummaryView el:el, store: store1, user: user, cart: cart
        ajaxSpy = sinon.stub $, 'ajax', (opt) =>
          opt.error status:400
        historySpy = sinon.spy Backbone.history, "navigate"
        view.render()
        $("#finishOrder", el).click()
      after ->
        ajaxSpy.restore()
        historySpy.restore()
      it 'has not redirected the user to the order finished route', ->
        historySpy.should.not.have.been.called
      it 'did not clear the cart', ->
        cart = Cart.get store1.slug
        cart.items().length.should.equal 2
