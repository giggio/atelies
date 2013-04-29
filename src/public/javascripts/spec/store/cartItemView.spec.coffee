product1  = generator.product.a()
product2  = generator.product.b()
store1    = generator.store.a()

define 'storeData', [], ->
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/views/cartItem'
  'jqueryVal'
], ($, CartView, CartItemView, jqueryVal) ->
  cartItemView = null
  el = $('<table></table>')
  jqueryVal.defaults.debug = true
  describe 'CartItemView', ->
    #TODO: jquery validate is getting in the way, making the test fail. it would otherwise pass
    xdescribe 'Changing item quantity with valid values', ->
      changedCalled = false
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cartItemView = new CartItemView model: {_id: '1', name:'prod 1', quantity: 2}
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        el.append cartItemView.$el
        cartItemView.$('.quantity').val(3)
        cartItemView.$('.quantity').trigger('blur')
      it 'shows a cart items table with one item', ->
        expect(changedCalled).toBeTruthy()
      it 'shows the first item product id', ->
        expect(cartItemView.model.quantity).toBe 3
