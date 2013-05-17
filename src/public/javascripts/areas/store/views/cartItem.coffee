define [
  'jquery'
  'backbone'
  '../models/cartItem'
  'text!./templates/cartItem.html'
  'backboneModelBinder'
  'backboneValidation'
], ($, Backbone, CartItem, cartItemTemplate, ModelBinder, Validation) ->
  class CartItemView extends Backbone.View
    initialize: (opt) ->
      @model = new CartItem opt.cartItem
      @cartItem = opt.cartItem
    events:
      "click .remove":'remove'
    template: cartItemTemplate
    render: ->
      @setElement @template
      binder = new ModelBinder()
      bindings =
        quantity:
          selector: "#quantity"
          converter: (direction, value) ->
            int = parseInt value
            if _.isNaN int then value else int
        _id: '._id'
        name: '.name'
      binder.bind @model, @el, bindings
      Validation.bind @
      @model.on 'change', =>
        if @model.isValid true
          @cartItem.quantity = @model.get 'quantity'
          @change()
    remove: -> removed @cartItem for removed in @removedCallbacks
    removed: (cb) -> @removedCallbacks.push cb
    removedCallbacks: []
    change: => callChanged @model for callChanged in @changedCallbacks
    changed: (cb) => @changedCallbacks.push cb
    changedCallbacks: []
