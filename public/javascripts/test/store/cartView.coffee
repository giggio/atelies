define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/models/cart'
  '../support/_specHelper'
], ($, CartView, Cart) ->
  product1  = generatorc.product.a()
  product2  = generatorc.product.b()
  store1    = generatorc.store.a()
  cartView = null
  el = $('<div></div>')
  describe 'CartView', ->
    describe 'Empty cart', ->
      before ->
        cartView = new CartView el:el, store: store1
        cartView.render()
      it 'does not show the cart items table', ->
        expect($("#cartItems", el).length).to.equal 0
    describe 'One item cart', ->
      before ->
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 1234567.1
        cartView = new CartView el:el, store: store1
        cartView.render()
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).to.equal 1
      it 'shows the first item product id', ->
        expect($("#cartItems .product", el).attr('data-id')).to.equal '1'
      it 'shows the first item name', ->
        expect($("#cartItems > tbody > tr > td:nth-child(2)", el).text()).to.equal 'produto 1'
      it 'shows the product price', ->
        $("#cartItems .price", el).text().should.equal 'R$ 1.234.567,10'
      it 'shows the total price per unit', ->
        $("#cartItems .totalPrice", el).text().should.equal 'R$ 1.234.567,10'
      it 'shows the total cart price', ->
        $("#cart #totalPrice", el).text().should.equal 'R$ 1.234.567,10'
    describe 'Removing item', ->
      before ->
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 11.1
        cart.addItem _id: '2', name: 'produto 2', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 11.1
        cartView = new CartView el:el, store: store1
        cartView.render()
        cartView.removeById '2'
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).to.equal 1
      it 'shows the first item product id', ->
        expect($("#cartItems .product", el).attr('data-id')).to.equal '1'
      it 'shows the first item name', ->
        expect($("#cartItems > tbody > tr > td:nth-child(2)", el).text()).to.equal 'produto 1'
    describe 'Clearing cart', ->
      before ->
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 11.1
        cart.addItem _id: '2', name: 'produto 2', quantity: 1, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 11.1
        cartView = new CartView el:el, store: store1
        cartView.render()
        $('#clearCart', el).trigger 'click'
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).to.equal 0
