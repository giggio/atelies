define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/models/cart'
  '../support/_specHelper'
], ($, CartView, Cart) ->
  product1  = generator.product.a()
  product2  = generator.product.b()
  store1    = generator.store.a()
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
        cart.addItem _id: '1', name: 'produto 1'
        cartView = new CartView el:el, store: store1
        cartView.render()
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).to.equal 1
      it 'shows the first item product id', ->
        expect($("#cartItems > tbody > tr > td:first-child", el).text()).to.equal '1'
      it 'shows the first item name', ->
        expect($("#cartItems > tbody > tr > td:nth-child(2)", el).text()).to.equal 'produto 1'
    describe 'Removing item', ->
      before ->
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1'
        cart.addItem _id: '2', name: 'produto 2'
        cartView = new CartView el:el, store: store1
        cartView.render()
        cartView.removeById '2'
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).to.equal 1
      it 'shows the first item product id', ->
        expect($("#cartItems > tbody > tr > td:first-child", el).text()).to.equal '1'
      it 'shows the first item name', ->
        expect($("#cartItems > tbody > tr > td:nth-child(2)", el).text()).to.equal 'produto 1'
    describe 'Clearing cart', ->
      before ->
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1'
        cart.addItem _id: '2', name: 'produto 2'
        cartView = new CartView el:el, store: store1
        cartView.render()
        $('#clearCart', el).trigger 'click'
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).to.equal 0
