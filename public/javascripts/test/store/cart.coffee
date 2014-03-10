define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'areas/store/models/cart'
], (Cart) ->
  describe 'The cart', ->
    beforeEach ->
      Cart.get().clear()
    afterEach ->
      Cart.get().clear()
    it 'delivers a list of carts when get is run without args', ->
      carts = Cart.get()
      expect(carts.length).to.equal 0
    it 'throws when a cart with empty string is requested', ->
      expect(-> Cart.get('')).to.throw
    it 'delivers the same cart when the store slug is the same', ->
      cart = Cart.get('store_1')
      otherCart = Cart.get('store_1')
      expect(cart).to.equal otherCart
    it 'delivers different carts when the store slug isnt the same', ->
      cart = Cart.get('store_1')
      otherCart = Cart.get('store_2')
      expect(cart).not.to.equal otherCart
    it 'is empty when cleared', ->
      cart = Cart.get('store_1')
      expect(cart.items.length).to.equal 0
    it 'is restored with items from previous session', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 1, shippingApplies: true
      cart.addItem item
      Cart._carts = null
      newCart = Cart.get('store_1')
      expect(cart).not.to.equal newCart
      similar(newCart.items()[0], item).should.be.true
    it 'is restored with items from previous session and without other cart items', ->
      cart1 = Cart.get('store_1')
      item1 = _id: 1, price: 1, shippingApplies: true
      cart1.addItem item1
      cart2 = Cart.get('store_2')
      item2 = _id: 2, price: 2, shippingApplies: true
      cart2.addItem item2
      Cart._carts = null
      newCart1 = Cart.get('store_1')
      similar(newCart1.items()[0], item1).should.be.true
      newCart2 = Cart.get('store_2')
      similar(newCart2.items()[0], item2).should.be.true
    it 'restored cart sets quantity', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      sameItem = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      Cart._carts = null
      newCart = Cart.get('store_1')
      cart.addItem sameItem
      expect(cart.items()[0].totalPrice).to.equal 22.2
      cart.totalPrice().should.equal 22.2
    it 'has items', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      expect(cart.items()).to.be.like [item]
    it 'works with a clean localStorage', ->
      localStorage.clear()
      cart = Cart.get('store_1')
      expect(cart.items().length).to.equal 0
    it 'has quantity on the items', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      expect(cart.items()[0].quantity).to.equal 1
    it 'when two same products are added it shows correct quantity', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      cart.addItem item
      expect(cart.items()[0].quantity).to.equal 2
    it 'when two same products are added it shows correct total price', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.11, shippingApplies: true
      cart.addItem item
      cart.addItem item
      expect(cart.items()[0].totalPrice).to.equal 22.22
    it 'when two different products are added it shows correct quantity', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      item2 = _id: 2, price: 11.1, shippingApplies: true
      cart.addItem item2
      items = cart.items()
      expect(items.length).to.equal 2
      expect(items[0].quantity).to.equal 1
      expect(items[1].quantity).to.equal 1
    it 'when removing an item from cart it is removed and does not come back', ->
      cart = Cart.get('store_5')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      item2 = _id: 2, price: 11.1, shippingApplies: true
      cart.addItem item2
      cart.removeById 1
      items = cart.items()
      expect(items.length).to.equal 1
      expect(items[0].quantity).to.equal 1
      expect(items[0]._id).to.equal 2
      expect(Cart.get('store_5').items().length).to.equal 1
    it 'when two different products are added it has correct price', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      item2 = _id: 2, price: 12.1, shippingApplies: true
      cart.addItem item2
      cart.totalPrice().should.equal 23.2
    it 'when two different products are added it has correct price', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      cart.addItem item
      cart.totalPrice().should.equal 22.2
    it 'does not have to calculate shipping with an empty cart', ->
      cart = Cart.get('store_1')
      cart.shippingCalculated().should.be.true
      cart.shippingSelected().should.be.false
    it 'does not have to calculate shipping with a cart that only has items that do not to be shipped', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: false
      cart.addItem item
      cart.shippingCalculated().should.be.true
      cart.shippingSelected().should.be.false
    it 'knows it has to calculate the shipping cost if it has one item', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      cart.shippingCalculated().should.be.false
      cart.shippingSelected().should.be.false
    it 'is aware shipping cost has been calculated but not selected', ->
      cart = Cart.get('store_1')
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.shippingCalculated().should.be.true
      cart.shippingSelected().should.be.false
    it 'is aware shipping cost has been calculated and selected', ->
      cart = Cart.get('store_1')
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.chooseShippingOption 'pac'
      cart.shippingCalculated().should.be.true
      cart.shippingSelected().should.be.true
    it 'sets shipping cost after shipping option is defined', ->
      cart = Cart.get('store_1')
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.chooseShippingOption 'pac'
      cart.shippingCost().should.equal 3.33
      cart.shippingOptionSelected().should.be.like { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
    it 'after product added, shipping cost needs to be calculated again', ->
      cart = Cart.get('store_1')
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.chooseShippingOption 'pac'
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      cart.shippingCalculated().should.be.false
      cart.shippingSelected().should.be.false
    it 'after product removed, shipping cost needs to be calculated again', ->
      cart = Cart.get('store_1')
      cart.addItem _id: 1, price: 11.1, shippingApplies: true
      cart.addItem _id: 2, price: 21.1, shippingApplies: true
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.chooseShippingOption 'pac'
      cart.removeById 1
      cart.shippingCalculated().should.be.false
      cart.shippingSelected().should.be.false
    it 'throws if shipping option selected does not exist', ->
      cart = Cart.get('store_1')
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      expect(-> cart.chooseShippingOption('oops')).to.throw Error
    it 'when two products are added and shipping calculated it has correct total sale amount', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      cart.addItem item
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.chooseShippingOption 'pac'
      cart.totalSaleAmount().should.equal 25.53
    it 'when quantity is set the shipping options are reset', ->
      cart = Cart.get('store_1')
      item = _id: 1, price: 11.1, shippingApplies: true
      cart.addItem item
      cart.setShippingOptions [
        { type: 'pac', name: 'PAC', cost: 3.33, days: 3 }
        { type: 'sedex', name: 'Sedex', cost: 4.44, days: 1 }
      ]
      cart.chooseShippingOption 'pac'
      item.setQuantity 3
      cart.shippingCalculated().should.be.false
      cart.shippingSelected().should.be.false
    it 'does not have shipping if empty', ->
      cart = Cart.get('store_1')
      cart.hasShipping().should.be.false
      cart.shippingCost().should.equal 0
    it 'does not have shipping if has one product without shipping', ->
      cart = Cart.get('store_1')
      cart.addItem _id: 1, price: 11.1, shippingApplies: false
      cart.hasShipping().should.be.false
    it 'has shipping if has one product with shipping', ->
      cart = Cart.get('store_1')
      cart.addItem _id: 1, price: 11.1, shippingApplies: true
      cart.hasShipping().should.be.true
    it 'has shipping if has one product with shipping and one without shipping', ->
      cart = Cart.get('store_1')
      cart.addItem _id: 1, price: 11.1, shippingApplies: true
      cart.addItem _id: 2, price: 11.1, shippingApplies: false
      cart.hasShipping().should.be.true
