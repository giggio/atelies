product1  = generator.product.a()
product2  = generator.product.b()
store1    = generator.store.a()

define 'storeData', [], ->
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/views/cartItem'
], ($, CartView, CartItemView) ->
  cartItemView = null
  describe 'CartItemView', ->
    describe 'Changing item quantity', ->
      changedCalled = false
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cartItemView = new CartItemView model: {id: '1', quantity: 2}
        cartItemView.changed -> changedCalled = true
        cartItemView.render()
        cartItemView.$('.quantity').val('3')
        cartItemView.$('.quantity').trigger('blur')
      it 'shows a cart items table with one item', ->
        expect(changedCalled).toBeTruthy()
      it 'shows the first item product id', ->
        expect(cartItemView.model.quantity).toBe 3
