Store   = require '../../../app/models/store'

describe 'Store', ->
  it 'requires name, city and state to be present', (done) ->
    store = new Store()
    store.validate (val) ->
      expect(val.errors.name.type).to.equal 'required'
      expect(val.errors.city.type).to.equal 'required'
      expect(val.errors.state.type).to.equal 'required'
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
    store = userEvaluating1 = rating1 = body1 = body2 = rating2 = null
    before (done) ->
      store = new Store()
      userEvaluating1 = generator.user.a()
      body1 = "body1"
      body2 = "body2"
      rating1 = 2
      rating2 = 5
      store = generator.store.a()
      store.addEvaluation {user: userEvaluating1, body: body1, rating: rating1}, ->
        store.addEvaluation {user: userEvaluating1, body: body2, rating: rating2}, done
    it 'has evaluations', ->
      store.evaluations.length.should.equal 2
      ev = store.evaluations[0]
      ev.user.should.equal userEvaluating1._id
      ev.userName.should.equal userEvaluating1.name
      ev.userEmail.should.equal userEvaluating1.email
      ev.body.should.equal body1
      ev.date.should.equalDate new Date()
      ev.rating.should.equal rating1
      ev = store.evaluations[1]
      ev.user.should.equal userEvaluating1._id
      ev.userName.should.equal userEvaluating1.name
      ev.userEmail.should.equal userEvaluating1.email
      ev.body.should.equal body2
      ev.date.should.equalDate new Date()
      ev.rating.should.equal rating2
    it 'has average evaluation', ->
      store.evaluationAvgRating.should.equal 3.5
    it 'knows the number of evaluations', ->
      store.numberOfEvaluations.should.equal 2
