Store   = require '../../../app/models/store'
Product = require '../../../app/models/product'
Order   = require '../../../app/models/order'
Q       = require 'q'

describe 'Store', ->
  it 'requires name, city and state to be present', (done) ->
    store = new Store()
    store.validate (val) ->
      expect(val.errors.name.kind).to.equal 'required'
      expect(val.errors.city.kind).to.equal 'required'
      expect(val.errors.state.kind).to.equal 'required'
      done()
  it 'sets the correct slug when store is created', ->
    store = new Store name:"Minha loja"
    expect(store.slug).to.equal 'minha_loja'
  it 'sets the correct slug when name is set', ->
    store = new Store()
    store.name = "Minha loja"
    expect(store.slug).to.equal 'minha_loja'
  it 'adds name keywords when created', ->
    store = new Store name:"Minha Loja"
    store.nameKeywords.should.be.like ['minha', 'loja']
  it 'adds name keywords when name is set', ->
    store = new Store()
    store.name = "Minha Loja"
    store.nameKeywords.should.be.like ['minha', 'loja']
  it 'name keywords is empty without a name', ->
    store = new Store()
    store.name = ""
    store.nameKeywords.should.be.like []
  it 'name keywords is null without a name', ->
    store = new Store()
    store.name = null
    store.nameKeywords.should.be.like []
  it 'sets pagseguro when not previously set', ->
    store = new Store()
    store.setPagseguro
      email: 'pagseguro@a.com'
      token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    store.pmtGateways.pagseguro.email.should.equal 'pagseguro@a.com'
    store.pmtGateways.pagseguro.token.should.equal 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
  it 'sets pagseguro when already set', ->
    store = new Store()
    store.pmtGateways.pagseguro =
      email: 'pagseguro@a.com'
      token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    store.setPagseguro
      email: 'pagseguro@a.com'
      token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    store.pmtGateways.pagseguro.email.should.equal 'pagseguro@a.com'
    store.pmtGateways.pagseguro.token.should.equal 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
  it 'unsets pagseguro when previously set', ->
    store = new Store()
    store.pmtGateways.pagseguro =
      email: 'pagseguro@a.com'
      token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    store.setPagseguro off
    expect(JSON.stringify(store.pmtGateways.pagseguro)).to.equal undefined
  it 'updates from simple', ->
    store = new Store()
    simple =
      name: 'a'
      phoneNumber: 'b'
      city: 'c'
      state: 'd'
      otherUrl: 'e'
      banner: 'f'
      pagseguro: true
      pagseguroEmail: 'pagseguro@a.com'
      pagseguroToken: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
    store.updateFromSimple simple
    store.phoneNumber.should.equal simple.phoneNumber
    store.city.should.equal simple.city
    store.state.should.equal simple.state
    store.otherUrl.should.equal simple.otherUrl
  describe 'evaluations', ->
    store = userEvaluating1 = rating1 = body1 = body2 = rating2 = evaluation1 = evaluation2 = order1 = order2 = null
    before ->
      store = new Store()
      userEvaluating1 = generator.user.d()
      body1 = "body1"
      body2 = "body2"
      rating1 = 2
      rating2 = 5
      store = generator.store.a()
      p1 = new Product price: 10, name: 'item 1'
      item1 = product: p1, quantity: 1
      p2 = new Product price: 20, name: 'item 2'
      item2 = product: p2, quantity: 1
      Order.create userEvaluating1, store, [ item1 ], 1, 'directSell'
      .then (order) ->
        order1 = order
        sinon.stub(Store, 'findById').yields null, store
        order.addEvaluation user: userEvaluating1, body: body1, rating: rating1
      .then (result) ->
        evaluation1 = result.evaluation
        Order.create userEvaluating1, result.store, [ item2 ], 1, 'directSell'
      .then (order) ->
        order2 = order
        order.addEvaluation user: userEvaluating1, body: body2, rating: rating2
      .then (result) ->
        evaluation2 = result.evaluation
    after -> Store.findById.restore()
    it 'has evaluations', ->
      evaluation1.user._id.should.equal userEvaluating1._id
      evaluation1.userName.should.equal userEvaluating1.name
      evaluation1.userEmail.should.equal userEvaluating1.email
      evaluation1.body.should.equal body1
      evaluation1.date.should.equalDate new Date()
      evaluation1.rating.should.equal rating1
      evaluation1.store._id.toString().should.equal store._id.toString()
      evaluation1.order._id.toString().should.equal order1._id.toString()
      evaluation2.user._id.should.equal userEvaluating1._id
      evaluation2.userName.should.equal userEvaluating1.name
      evaluation2.userEmail.should.equal userEvaluating1.email
      evaluation2.body.should.equal body2
      evaluation2.date.should.equalDate new Date()
      evaluation2.rating.should.equal rating2
      evaluation2.store._id.toString().should.equal store._id.toString()
      evaluation2.order._id.toString().should.equal order2._id.toString()
    it 'has average evaluation', ->
      store.evaluationAvgRating.should.equal 3.5
    it 'knows the number of evaluations', ->
      store.numberOfEvaluations.should.equal 2
    it 'has orders with evaluation', ->
      order1.evaluation._id.toString().should.equal evaluation1._id.toString()
      order2.evaluation._id.toString().should.equal evaluation2._id.toString()
