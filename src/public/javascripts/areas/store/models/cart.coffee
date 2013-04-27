define ['underscore'], (_) ->
  class Cart
    @_carts: null
    @get: (storeSlug) ->
      unless @_carts?
        @_carts = []
        @_carts.clear = -> cart.clear() for cart in @
      switch storeSlug
        when '' then throw 'Cart needs a string'
        when undefined then return @_carts
      cart = _.findWhere @_carts, storeSlug: storeSlug
      unless cart?
        cart = new Cart storeSlug
        @_carts.push cart
      cart
    constructor: (@storeSlug) ->
      @_items = []
      previousSessionItems = localStorage.getItem "cartItems#{@storeSlug}"
      if previousSessionItems? then @_items = JSON.parse previousSessionItems
    _items: []
    _save: ->
      localStorage.setItem "cartItems#{@storeSlug}", JSON.stringify @_items
    addItem: (item) ->
      #console.log "adding item: #{JSON.stringify(item)} to cart #{JSON.stringify(@)} items:#{JSON.stringify(@_items)}"
      if existingItem = _.findWhere @_items, { _id: item._id }
        existingItem.quantity++
      else
        item.quantity = 1
        @_items.push item
      @_save()
    clear: ->
      @_items = []
      localStorage.removeItem "cartItems#{@storeSlug}"
    items: -> @_items
