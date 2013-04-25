define [
  'areas/store/models/cart'
], (Cart) ->
  describe 'Cart', ->
    afterEach ->
      Cart.get().clear()
    it 'delivers a list of carts when get is run without args', ->
      carts = Cart.get()
      expect(carts.length).toBe 0
    it 'throws when a cart with empty string is requested', ->
      expect(-> Cart.get('')).toThrow()
    it 'delivers the same cart when the store slug is the same', ->
      cart = Cart.get('store_1')
      otherCart = Cart.get('store_1')
      expect(cart).toBe otherCart
    it 'delivers different carts when the store slug isnt the same', ->
      cart = Cart.get('store_1')
      otherCart = Cart.get('store_2')
      expect(cart).not.toBe otherCart
    it 'is empty when cleared', ->
      cart = Cart.get('store_1')
      expect(cart.items.length).toBe 0
    it 'is restored with items from previous session', ->
      cart = Cart.get('store_1')
      item = _id: 1
      cart.addItem item
      Cart._carts = null
      newCart = Cart.get('store_1')
      expect(cart).not.toBe newCart
      expect(newCart.items()).toEqual [item]
    it 'is restored with items from previous session and without other cart items', ->
      cart1 = Cart.get('store_1')
      item1 = _id: 1
      cart1.addItem item1
      cart2 = Cart.get('store_2')
      item2 = _id: 2
      cart2.addItem item2
      Cart._carts = null
      newCart1 = Cart.get('store_1')
      expect(newCart1.items()).toEqual [item1]
      newCart2 = Cart.get('store_2')
      expect(newCart2.items()).toEqual [item2]
    it 'has items', ->
      cart = Cart.get('store_1')
      item = _id: 1
      cart.addItem item
      expect(cart.items()).toEqual [item]
    it 'works with a clean localStorage', ->
      localStorage.clear()
      cart = Cart.get('store_1')
      expect(cart.items().length).toBe 0
    it 'has quantity on the items', ->
      cart = Cart.get('store_1')
      item = _id: 1
      cart.addItem item
      expect(cart.items()[0].quantity).toBe 1
    it 'when two same products are added it shows correct quantity', ->
      cart = Cart.get('store_1')
      item = _id: 1
      cart.addItem item
      cart.addItem item
      expect(cart.items()[0].quantity).toBe 2
    it 'when two differente products are added it shows correct quantity', ->
      cart = Cart.get('store_1')
      item = _id: 1
      cart.addItem item
      item2 = _id: 2
      cart.addItem item2
      items = cart.items()
      expect(items.length).toBe 2
      expect(items[0].quantity).toBe 1
      expect(items[1].quantity).toBe 1
