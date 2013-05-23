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
      "._id":"html:_id"
      ".name":"html:name"
    template: cartItemTemplate
    render: ->
    remove: -> removed @cartItem for removed in @removedCallbacks
    removed: (cb) -> @removedCallbacks.push cb
    removedCallbacks: []
    change: => callChanged @model for callChanged in @changedCallbacks
    changed: (cb) => @changedCallbacks.push cb
    changedCallbacks: []
