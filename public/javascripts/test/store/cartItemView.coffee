define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/views/cartItem'
  'backboneConfig'
], ($, CartView, CartItemView) ->
  describe 'CartItemView', ->
    cartItemView = null
    el = $('<table></table>')
    describe 'Changing item quantity with valid values', ->
      changedCalled = false
      before ->
        cartItemView = new CartItemView cartItem: {_id: '1', name:'prod 1', quantity: 2}
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        el.append cartItemView.$el
        cartItemView.$('.quantity').val(3).change()
      it 'shows a cart items table with one item', ->
        changedCalled.should.be.true
      it 'shows the first item product id', ->
        expect(cartItemView.cartItem.quantity).to.equal 3
    describe 'Changing item quantity with invalid values', ->
      changedCalled = false
      before ->
        cartItemView = new CartItemView cartItem: {_id: '1', name:'prod 1', quantity: 2}
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        el.append cartItemView.$el
        cartItemView.$('.quantity').val('a').change()
      it 'shows a cart items table with one item', ->
        changedCalled.should.be.false
      it 'shows the first item product id', ->
        expect(cartItemView.cartItem.quantity).to.equal 2
      it 'shows validation message', ->
        $(".quantity ~ .tooltip .tooltip-inner", el).text().should.equal 'A quantidade deve ser um número.'
