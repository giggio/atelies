product1  = generator.product.a()
product2  = generator.product.b()
store1    = generator.store.a()

define 'storeData', [], ->
define [
  'jquery'
  'areas/store/views/cart'
  'areas/store/models/cart'
], ($, CartView, Cart) ->
  cartView = null
  el = $('<div></div>')
  describe 'CartView', ->
    describe 'Empty cart', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cartView = new CartView el:el, storeData:
          store: store1
          products: [product1, product2]
        cartView.render()
      it 'does not show the cart items table', ->
        expect($("#cartItems", el).length).toBe 0
    describe 'One item cart', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1'
        cartView = new CartView el:el, storeData:
          store: store1
          products: [product1, product2]
        cartView.render()
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).toBe 1
      it 'shows the first item product id', ->
        expect($("#cartItems > tbody > tr > td:first-child", el).html()).toBe '1'
      it 'shows the first item name', ->
        expect($("#cartItems > tbody > tr > td:nth-child(2)", el).html()).toBe 'produto 1'
    describe 'Removing item', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1'
        cart.addItem _id: '2', name: 'produto 2'
        cartView = new CartView el:el, storeData:
          store: store1
          products: [product1, product2]
        cartView.render()
        cartView.removeById '2'
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).toBe 1
      it 'shows the first item product id', ->
        expect($("#cartItems > tbody > tr > td:first-child", el).html()).toBe '1'
      it 'shows the first item name', ->
        expect($("#cartItems > tbody > tr > td:nth-child(2)", el).html()).toBe 'produto 1'
    describe 'Clearing cart', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        cart = Cart.get(store1.slug)
        cart.clear()
        cart.addItem _id: '1', name: 'produto 1'
        cart.addItem _id: '2', name: 'produto 2'
        cartView = new CartView el:el, storeData:
          store: store1
          products: [product1, product2]
        cartView.render()
        $('#clearCart', el).trigger 'click'
      it 'shows a cart items table with one item', ->
        expect($("#cartItems > tbody > tr", el).length).toBe 0
