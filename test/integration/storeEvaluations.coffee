require './support/_specHelper'
Store                  = require '../../app/models/store'
Order                  = require '../../app/models/order'
Product                = require '../../app/models/product'
StoreEvaluationsPage   = require './support/pages/storeEvaluationsPage'
request                = require 'request'
md5                    = require("blueimp-md5").md5
Postman                = require '../../app/models/postman'
Q                      = require 'q'

describe 'Store evaluations page', ->
  page = store = null
  before ->
    page = new StoreEvaluationsPage()
    whenServerLoaded()

  describe 'showing', ->
    userEvaluating1 = userEvaluating2 = body1 = body2 = rating1 = rating2 = null
    before ->
      cleanDB().then ->
        userEvaluating1 = generator.user.d()
        userEvaluating1.save()
        userEvaluating2 = generator.user.d()
        userEvaluating2.name = "John Smith"
        userEvaluating2.save()
        body1 = "body1"
        body2 = "body2"
        rating1 = 2
        rating2 = 5
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        item1 = product: product1, quantity: 1
        Order.create userEvaluating1, store, [ item1 ], 1, 'directSell'
        .then (order) ->
          order.save()
          order.addEvaluation user: userEvaluating1, body: body1, rating: rating1
          .then (result) ->
            store = result.store
            order.save()
            result.evaluation.save()
            result.store.save()
            Order.create userEvaluating2, store, [ item1 ], 2, 'directSell'
            .then ->
              order.save()
              order.addEvaluation user: userEvaluating2, body: body2, rating: rating2
              .then (result) ->
                store = result.store
                order.save()
                result.evaluation.save()
                store.save()
                page.visit "store_1"
    it 'shows evaluations', ->
      page.evaluations().then (evaluations) ->
        evaluations.length.should.equal 2
        evaluations[0].userName.should.equal userEvaluating1.name
        evaluations[0].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userEvaluating1.email.toLowerCase())}?d=mm&r=pg&s=50"
        evaluations[0].body.should.equal body1
        evaluations[0].rating.should.equal rating1
        evaluations[1].userName.should.equal userEvaluating2.name
        evaluations[1].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userEvaluating2.email.toLowerCase())}?d=mm&r=pg&s=50"
        evaluations[1].body.should.equal body2
        evaluations[1].rating.should.equal rating2
