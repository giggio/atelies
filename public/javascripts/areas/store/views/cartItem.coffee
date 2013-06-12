define [
  'jquery'
  'backbone'
  '../models/cartItem'
  'text!./templates/cartItem.html'
  'backboneValidation'
], ($, Backbone, CartItem, cartItemTemplate, Validation) ->
  class CartItemView extends Backbone.Open.View
    initialize: (opt) ->
      @model = new CartItem opt.cartItem
      @cartItem = opt.cartItem
      @setElement @template
      Validation.bind @, selector: 'class'
      @model.on 'change', =>
        if @model.isValid()
          @cartItem.quantity = @model.get 'quantity'
          @change()
    events:
      "click .remove":'remove'
    bindings:
      ".quantity":"value:integerOr(quantity)"
      ".name":"html:name"
      ".picture":"attr:{src:picture}"
      ".product":"attr:{'data-id':_id}"
      ".nameLink":"attr:{href:url}"
      ".pictureLink":"attr:{href:url}"
      ".price":"html:price"
    template: cartItemTemplate
    render: ->
    remove: -> removed @cartItem for removed in @removedCallbacks
    removed: (cb) -> @removedCallbacks.push cb
    removedCallbacks: []
    change: => callChanged @model for callChanged in @changedCallbacks
    changed: (cb) => @changedCallbacks.push cb
    changedCallbacks: []
