define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/cartItem.html'
], ($, Backbone, Handlebars, cartItemTemplate) ->
  class CartItemView extends Backbone.View
    events:
      'click .remove':'remove'
    template: cartItemTemplate
    render: ->
      context = Handlebars.compile @template
      @$el.append context @model
    remove: -> removed @model for removed in @removedCallbacks
    removed: (cb) -> @removedCallbacks.push cb
    removedCallbacks: []
