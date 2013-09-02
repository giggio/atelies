define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/order.html'
  '../../../converters'
], ($, _, Backbone, Handlebars, orderTemplate, converters) ->
  class OrderView extends Backbone.Open.View
    template: orderTemplate
    initialize: (opt) ->
      @user = opt.user
      @order = opt.order
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      order = @order
      order.shippingCost = converters.currency order.shippingCost
      order.totalSaleAmount = converters.currency order.totalSaleAmount
      order.totalProductsPrice = converters.currency order.totalProductsPrice
      order.orderDate = converters.prettyDate new Date(order.orderDate)
      order.items = _.map @order.items, (i) ->
        _id: i._id
        storeSlug: order.storeSlug
        slug: i.slug
        name: i.name
        picture: i.picture
        price: converters.currency i.price
        quantity: i.quantity
        totalPrice: converters.currency i.totalPrice
      @$el.html context user: @user, order: order
      @$("#ratingStars").jRating
        bigStarsPath : 'public/javascripts/lib/jrating/jquery/icons/stars.png'
        smallStarsPath : 'public/javascripts/lib/jrating/jquery/icons/small.png'
        sendRequest: off
        rateMax: 5
        canRateAgain: on
        step: true
        showRateInfo: off
