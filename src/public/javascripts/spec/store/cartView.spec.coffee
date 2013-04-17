product1  = generator.product.a()
product2  = generator.product.b()
store1    = generator.store.a()

define 'storeData', [], ->
define [
  'jquery'
  'areas/store/views/cart'
], ($, CartView) ->
  cartView = null
  el = $('<div></div>')
  describe 'CartView', ->
    describe 'Empty cart', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cartView = new CartView el:el
        cartView.storeData =
          store: store1
          products: [product1, product2]
        cartView.render()
      it 'shows the cart items table', ->
        expect($('#cartItems', el).length).toBe 1
      it 'shows an empty cart items table', ->
        expect($("#cartItems > tbody > tr", el).length).toBe 0
