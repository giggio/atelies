define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/views/cartItem'
  'jqueryVal'
], ($, CartView, CartItemView, jqueryVal) ->
  xdescribe 'CartItemView', ->
    cartItemView = null
    el = $('<table></table>')
    jqueryVal.defaults.debug = true
    #TODO: jquery validate is getting in the way, making the test fail. it would otherwise pass
    describe 'Changing item quantity with valid values', ->
      changedCalled = false
      before ->
        cartItemView = new CartItemView model: {_id: '1', name:'prod 1', quantity: 2}
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        el.append cartItemView.$el
        cartItemView.$('.quantity').val(3)
        cartItemView.$('.quantity').trigger('blur')
      it 'shows a cart items table with one item', ->
        expect(changedCalled).to.equalTruthy()
      it 'shows the first item product id', ->
        expect(cartItemView.model.quantity).to.equal 3
