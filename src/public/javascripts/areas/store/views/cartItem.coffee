define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/cartItem.html'
  'jqueryVal'
], ($, Backbone, Handlebars, cartItemTemplate) ->
  class CartItemView extends Backbone.View
    events:
      "click .remove":'remove'
      "blur .quantity":'updateQuantity'
    template: cartItemTemplate
    render: ->
      context = Handlebars.compile @template
      @setElement $ context @model
      @setFormsInValidationFields @$ '.quantity'
    remove: -> removed @model for removed in @removedCallbacks
    removed: (cb) -> @removedCallbacks.push cb
    removedCallbacks: []
    change: => callChanged @model for callChanged in @changedCallbacks
    changed: (cb) => @changedCallbacks.push cb
    changedCallbacks: []
    updateQuantity: =>
      quantity = @$('.quantity')
      quantity.validate()
      return unless quantity.valid()
      @model.quantity = parseInt quantity.val()
      @change()
    setFormsInValidationFields: (selector) ->
      @$('.quantityHolder').append $("<form style='margin: 0;'>").append(selector)
