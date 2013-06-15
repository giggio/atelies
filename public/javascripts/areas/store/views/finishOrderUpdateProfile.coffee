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
      @store = opt.store
    render: =>
      context = Handlebars.compile @template
      @$el.html context user: @user, storeSlug: @store.slug
      setTimeout (=> window.location = "/account/updateProfile?redirectTo=/#{@store.slug}%23finishOrder/shipping"), 10000
