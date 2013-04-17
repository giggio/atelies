define [], ->
  class Cart
    @_cart: null
    @get: ->
      unless @_cart?
        @_cart = new Cart()
      @_cart
    constructor: ->
      throw 'Cart is a singleton.' if Cart._cart?
      previousSessionItems = localStorage.getItem 'cartItems'
      if previousSessionItems?
        @_items = JSON.parse previousSessionItems
    _items: []
    _save: ->
      localStorage.setItem 'cartItems', JSON.stringify @_items
    addItem: (item) ->
      @_items.push item
      @_save()
    clear: ->
      @_items = []
      localStorage.removeItem 'cartItems'
    items: -> @_items
