define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  '../models/evaluations'
  'text!./templates/order.html'
  '../../../converters'
], ($, _, Backbone, Handlebars, Evaluations, orderTemplate, converters) ->
  class OrderView extends Backbone.Open.View
    events:
      'click #createEvaluation': '_createEvaluation'
    template: orderTemplate
    initialize: (opt) ->
      @user = opt.user
      @order = opt.order
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      order = _.extend {}, @order
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
      @_showStars()
    _showStars: ->
      if @order.evaluation?
        @$("#ratingStars").jRating
          bigStarsPath : "#{staticPath}/images/jrating/stars.png"
          smallStarsPath : "#{staticPath}/images/jrating/small.png"
          rateMax: 5
          showRateInfo: off
          isDisabled: on
      else
        @$("#newRatingStars").jRating
          bigStarsPath : "#{staticPath}/images/jrating/stars.png"
          smallStarsPath : "#{staticPath}/images/jrating/small.png"
          sendRequest: off
          rateMax: 5
          canRateAgain: on
          step: true
          showRateInfo: off
          nbRates: 9999
          onClick : (el, rating) => @evaluationRating = rating
    _createEvaluation: ->
      evals = new Evaluations null, orderId: @order._id
      ratingAttr = body: @$('#newEvaluationBody').val(), rating: @evaluationRating
      ev = evals.create ratingAttr, forceUpdate: off
      if ev is false
        @showDialog "Você precisa informar a classificação, clique em uma das estrelas para classificar a loja e o pedido de 1 a 5.", "Classificação inválida"
      else
        @order.evaluation = ev.attributes
        @render()
