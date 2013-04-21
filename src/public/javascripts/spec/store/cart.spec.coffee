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
      item = _id: 1
      cart.addItem item
      Cart._cart = null
      newCart = Cart.get()
      expect(cart).not.toBe newCart
      expect(newCart.items()).toEqual [item]
    it 'has items', ->
      cart = Cart.get()
      item = _id: 1
      cart.addItem item
      expect(cart.items()).toEqual [item]
    it 'works with a clean localStorage', ->
      localStorage.clear()
      cart = Cart.get()
      expect(cart.items().length).toBe 0
    it 'has quantity on the items', ->
      cart = Cart.get()
      item = _id: 1
      cart.addItem item
      expect(cart.items()[0].quantity).toBe 1
    it 'when two same products are added it shows correct quantity', ->
      cart = Cart.get()
      item = _id: 1
      cart.addItem item
      cart.addItem item
      expect(cart.items()[0].quantity).toBe 2
    it 'when two differente products are added it shows correct quantity', ->
      cart = Cart.get()
      item = _id: 1
      cart.addItem item
      item2 = _id: 2
      cart.addItem item2
      items = cart.items()
      expect(items.length).toBe 2
      expect(items[0].quantity).toBe 1
      expect(items[1].quantity).toBe 1
