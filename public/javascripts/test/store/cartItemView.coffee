define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/models/cart'
  'areas/store/views/cart'
  'areas/store/views/cartItem'
  'backboneConfig'
], ($, Cart, CartView, CartItemView) ->
  describe 'CartItemView', ->
    cartItemView = null
    el = $('<table></table>')
    describe 'Changing item quantity with valid values', ->
      changedCalled = false
      before ->
        cart = Cart.get('store_1')
        cart.clear()
        item = _id: '1', name:'prod 1', quantity: 2, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 11.1
        cart.addItem item
        cartItemView = new CartItemView cartItem: item
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        el.append cartItemView.$el
        cartItemView.$('.quantity').val(3).change()
      it 'shows a cart items table with one item', ->
        changedCalled.should.be.true
      it 'shows the quantity', ->
        expect(cartItemView.cartItem.quantity).to.equal 3
    describe 'Changing item quantity with invalid values', ->
      changedCalled = false
      before ->
        cart = Cart.get('store_1')
        cart.clear()
        item = _id: '1', name:'prod 1', quantity: 2, picture: 'http://someurl.com', url: 'store_1#prod_1', price: 11.1
        cart.addItem item
        cartItemView = new CartItemView cartItem: item
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        el.append cartItemView.$el
        cartItemView.$('.quantity').val('a').change()
      it 'shows a cart items table with one item', ->
        changedCalled.should.be.false
      it 'shows the quantity', ->
        expect(cartItemView.cartItem.quantity).to.equal 1
      it 'shows validation message', ->
        $(".quantity ~ .tooltip .tooltip-inner", el).text().should.equal 'A quantidade deve ser um número.'
