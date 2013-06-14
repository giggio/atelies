define [
  'jquery'
  'backbone'
  'handlebars'
  '../models/products'
  '../models/cart'
  'text!./templates/finishOrderUpdateProfile.html'
  './cartItem'
  '../../../converters'
], ($, Backbone, Handlebars, Products, Cart, finishOrderUpdateProfileTemplate, CartItemView, converters) ->
  class CartView extends Backbone.View
    template: finishOrderUpdateProfileTemplate
    initialize: (opt) =>
      @user = opt.user
    render: =>
      context = Handlebars.compile @template
      @$el.html context user: @user
      setTimeout (-> window.location = "/account/updateProfile"), 10000
