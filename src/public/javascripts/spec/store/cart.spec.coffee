define [
  'areas/store/models/cart'
], (Cart) ->
  describe 'Cart', ->
    afterEach ->
      Cart.get().clear()
    it 'is empty when cleared', ->
      cart = Cart.get()
      expect(cart.items.length).toBe 0
    it 'cannot be created twice', ->
      Cart.get()
      expect(-> new Cart()).toThrow()
    it 'is a singleton', ->
      cart = Cart.get()
      expect(Cart.get()).toBe cart
    it 'is restored with items from previous session', ->
      cart = Cart.get()
      item = id: 1
      cart.addItem item
      Cart._cart = null
      newCart = Cart.get()
      expect(cart).not.toBe newCart
      expect(newCart.items()).toEqual [item]
    it 'has items', ->
      cart = Cart.get()
      item = id: 1
      cart.addItem item
      expect(cart.items()).toEqual [item]
    it 'works with a clean localStorage', ->
      localStorage.clear()
      cart = Cart.get()
      expect(cart.items().length).toBe 0
