require './support/_specHelper'
Store                     = require '../../app/models/store'
Product                   = require '../../app/models/product'
User                      = require '../../app/models/user'
StoreEvaluation           = require '../../app/models/storeEvaluation'
ProductComment            = require '../../app/models/productComment'
StoreEvaluation           = require '../../app/models/storeEvaluation'
Order                     = require '../../app/models/order'
AdminManageStorePage      = require './support/pages/adminManageStorePage'
Q                         = require 'q'

describe 'Admin manage store page', ->
  page = exampleStore = otherStore = userSeller = undefined
  before -> page = new AdminManageStorePage()

  describe 'updates a store', ->
    before ->
      cleanDB().then ->
        exampleStore = generator.store.a()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        otherStore = generator.store.d().toJSON()
        Q.all [Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then -> page.setFieldsAs otherStore
      .then page.clickUpdateStoreButton
    it 'shows store updated message', -> page.message().then (msg) -> msg.endsWith("Loja atualizada com sucesso").should.be.true
    it 'updated a new store with correct information', ->
      Q.ninvoke(Store, "find").then (stores) ->
        stores.length.should.equal 1
        store = stores[0]
        expect(store).not.to.be.null
        expect(store.slug).to.equal otherStore.slug
        expect(store.name).to.equal otherStore.name
        expect(store.email).to.equal otherStore.email
        expect(store.description).to.equal otherStore.description
        expect(store.urlFacebook).to.be.undefined
        expect(store.urlTwitter).to.be.undefined
        expect(store.phoneNumber).to.equal otherStore.phoneNumber
        expect(store.city).to.equal otherStore.city
        expect(store.state).to.equal otherStore.state
        expect(store.zip).to.equal otherStore.zip
        expect(store.otherUrl).to.equal otherStore.otherUrl
    it 'kept the store to the user', -> Q.ninvoke(User, "findById", userSeller.id).then (user) -> user.stores.length.should.equal 1
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{otherStore.slug}"

  describe 'updates to use pagseguro', ->
    before ->
      cleanDB()
      .then ->
        exampleStore = generator.store.c()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then page.clickSetPagseguroButton
      .then -> page.setPagseguroValuesAs email: 'pagseguro@a.com', token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
      .then page.clickConfirmSetPagseguroButton
      .then waitSeconds 5
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{exampleStore.slug}"
    it 'shows store updated message', -> page.message().then (msg) -> msg.endsWith("Loja atualizada com sucesso").should.be.true
    it 'updated the store and set pagseguro', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        store.pmtGateways.pagseguro.email.should.equal 'pagseguro@a.com'
        store.pmtGateways.pagseguro.token.should.equal 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'

  describe 'updates to use paypal', ->
    before ->
      cleanDB()
      .then ->
        exampleStore = generator.store.c()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then page.clickSetPaypalButton
      .then -> page.setPaypalValuesAs clientId: 'someid', secret: 'somesecret'
      .then page.clickConfirmSetPaypalButton
      .then waitSeconds 5
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{exampleStore.slug}"
    it 'shows store updated message', -> page.message().then (msg) -> msg.endsWith("Loja atualizada com sucesso").should.be.true
    it 'updated the store and set paypal', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        store.pmtGateways.paypal.clientId.should.equal 'someid'
        store.pmtGateways.paypal.secret.should.equal 'somesecret'

  describe 'does not update a store to use pagseguro if information is missing', ->
    before ->
      cleanDB().then ->
        exampleStore = generator.store.c()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then page.clickSetPagseguroButton
      .then -> page.setPagseguroValuesAs email: '', token: ''
      .then page.clickConfirmSetPagseguroButton
    it 'is at the store manage page', -> page.currentUrl().should.become "http://localhost:8000/admin/manageStore/#{exampleStore._id}"
    it 'does not show store updated message', -> page.hasMessage().should.eventually.be.false
    it 'shows error messages', ->
      Q.all [
        page.pagseguroEmailErrorMsg().should.become "O e-mail deve existir e ser válido."
        page.pagseguroTokenErrorMsg().should.become 'O token do PagSeguro é obrigatório e deve possuir 32 caracteres.'
      ]
    it 'did not update the store and set pagseguro', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        expect(store.pmtGateways.pagseguro.email).to.be.undefined
        expect(store.pmtGateways.pagseguro.token).to.be.undefined

  describe 'does not update a store to use paypal if information is missing', ->
    before ->
      cleanDB().then ->
        exampleStore = generator.store.c()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then page.clickSetPaypalButton
      .then -> page.setPaypalValuesAs clientId: '', secret: ''
      .then page.clickConfirmSetPaypalButton
    it 'is at the store manage page', -> page.currentUrl().should.become "http://localhost:8000/admin/manageStore/#{exampleStore._id}"
    it 'does not show store updated message', -> page.hasMessage().should.eventually.be.false
    it 'shows error messages', ->
      Q.all [
        page.paypalClientIdErrorMsg().should.become 'O id do cliente do Paypal deve ser informado.'
        page.paypalSecretErrorMsg().should.become 'O segredo do Paypal é obrigatório.'
      ]
    it 'did not update the store and set paypal', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        expect(store.pmtGateways.paypal.clientId).to.be.undefined
        expect(store.pmtGateways.paypal.secret).to.be.undefined

  describe 'updates to do not use pagseguro', ->
    before ->
      cleanDB()
      .then ->
        exampleStore = generator.store.a()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then page.clickUnsetPagseguroButton
      .then page.clickConfirmUnsetPagseguroButton
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{exampleStore.slug}"
    it 'shows store updated message', -> page.message().then (msg) -> msg.endsWith("Loja atualizada com sucesso").should.be.true
    it 'updated the store and unset pagseguro', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        expect(store.pmtGateways.pagseguro.email).to.be.undefined
        expect(store.pmtGateways.pagseguro.token).to.be.undefined

  describe 'updates to do not use paypal', ->
    before ->
      cleanDB()
      .then ->
        exampleStore = generator.store.a()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then page.clickUnsetPaypalButton
      .then page.clickConfirmUnsetPaypalButton
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{exampleStore.slug}"
    it 'shows store updated message', -> page.message().then (msg) -> msg.endsWith("Loja atualizada com sucesso").should.be.true
    it 'updated the store and unset paypal', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        expect(store.pmtGateways.paypal.clientId).to.be.undefined
        expect(store.pmtGateways.paypal.secret).to.be.undefined

  describe 'does not update a store (missing or wrong info)', ->
    before ->
      cleanDB().then ->
        exampleStore = generator.store.a()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then ->
        emptyStore = generator.store.empty()
        emptyStore.email = "bla"
        emptyStore.otherUrl = "def"
        page.setFieldsAs emptyStore
      .then page.clickUpdateStoreButton
    it 'is at the store manage page', -> page.currentUrl().should.become "http://localhost:8000/admin/manageStore/#{exampleStore._id}"
    it 'does not show store updated message', -> page.hasMessage().should.eventually.be.false
    it 'shows validation messages', ->
      page.errorMessagesIn("#manageStoreBlock").then (msgs) ->
        msgs.name.should.equal "Informe o nome da loja."
        msgs.email.should.equal "O e-mail deve ser válido."
        msgs.city.should.equal "Informe a cidade."
        msgs.zip.should.equal "Informe o CEP no formato 99999-999."
        msgs.otherUrl.should.equal "Informe um link válido para o outro site, começando com http ou https."
    it 'did not update the store with wrong info', ->
      Store.findBySlug(exampleStore.slug).then (store) ->
        expect(store).not.to.be.null
        expect(store.slug).to.equal exampleStore.slug
        expect(store.name).to.equal exampleStore.name
        expect(store.email).to.equal exampleStore.email
        expect(store.description).to.equal exampleStore.description
        expect(store.urlFacebook).to.equal exampleStore.urlFacebook
        expect(store.urlTwitter).to.equal exampleStore.urlTwitter
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.zip).to.equal exampleStore.zip
        expect(store.otherUrl).to.equal exampleStore.otherUrl

  describe 'updating a store keeps products connected to store', ->
    otherName = otherSlug = null
    before ->
      otherName = "My Super Cool Store"
      otherSlug = "my_super_cool_store"
      cleanDB().then ->
        exampleStore = generator.store.a()
        product = generator.product.a()
        userSeller = generator.user.c()
        userSeller.stores.push exampleStore
        otherStore = generator.store.d().toJSON()
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save'), Q.ninvoke(product, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
      .then -> page.setName otherName
      .then page.clickUpdateStoreButton
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{otherSlug}"
    it 'updated the store name and slug', ->
      Q.ninvoke(Store, "find").then (stores) ->
        stores.length.should.equal 1
        store = stores[0]
        store.name.should.equal otherName
        store.slug.should.equal otherSlug
    it 'updated the product name and slug', ->
      Q.ninvoke(Product, "find").then (products) ->
        products.length.should.equal 1
        product = products[0]
        product.storeSlug.should.to.equal otherSlug
        product.storeName.should.to.equal otherName

  describe "can't see a store on management if you don't own it", ->
    before ->
      cleanDB().then ->
        exampleStore = generator.store.a()
        userSeller = generator.user.c()
        Q.all [ Q.ninvoke(exampleStore, 'save'), Q.ninvoke(userSeller, 'save') ]
      .then -> page.loginFor userSeller._id
      .then -> page.visit exampleStore._id.toString()
    it "shows store can't be shown message", -> page.getDialogMsg().should.become "Você não tem permissão para alterar essa loja. Entre em contato diretamente com o administrador."
    it 'redirects user to admin page', -> page.currentUrl().should.become "http://localhost:8000/admin"

  describe 'delete store', ->
    userEvaluating = store = product = order = null
    before ->
      cleanDB()
      .then ->
        store = generator.store.a()
        Q.ninvoke store, 'save'
      .then ->
        savingProduct = for i in [0..2]
          p = generator.product.a()
          if i is 0 then product = p
          p.storeSlug = store.slug
          p.name+="#{store.name}_#{i}_#{p.name}"
          Q.ninvoke p, 'save'
        Q.all savingProduct
      .then ->
        userSeller = generator.user.c()
        userSeller.stores.push store
        Q.ninvoke userSeller, 'save'
      .then ->
        userEvaluating = generator.user.d()
        Q.ninvoke userEvaluating, 'save'
      .then ->
        item = product: product, quantity: 1
        Order.create userEvaluating, store, [ item ], 1, 'directSell'
      .then (o) ->
        order = o
        Q.ninvoke order, 'save'
      .then -> order.addEvaluation user: userEvaluating, body: 'some body', rating: 2
      .then (result) -> Q.ninvoke result.evaluation, 'save'
      .then -> Q.all [Q.ninvoke(order, 'save'), Q.ninvoke store, 'save']
      .then ->
        userCommenting = generator.user.b()
        Q.ninvoke userCommenting, 'save'
      .spread (userCommenting) -> product.addComment user: userCommenting, body: 'comment body'
      .then (comment) -> Q.ninvoke comment, 'save'
      .then -> page.loginFor userSeller._id
      .then -> page.visit store._id.toString()
      .then page.clickDeleteStore
      .then page.clickConfirmDeleteStore
      .then page.clickConfirmConfirmDeleteStore
    it 'is at the admin page', -> page.currentUrl().should.become "http://localhost:8000/admin/home"
    it "shows store deleted message", -> page.getDialogMsg().should.become "Loja removida com sucesso."
    it 'deleted the store', -> Store.findBySlug(store.slug).should.eventually.be.null
    it 'deleted the store products', -> Product.findByStoreSlug(store.slug).should.eventually.be.like []
    it 'deleted the store orders', -> Q.ninvoke(Order, 'find', store:store._id).should.eventually.be.like []
    it 'deleted the store product comments', -> Q.ninvoke(ProductComment, 'find').should.eventually.be.like []
    it 'deleted the store evaluations', -> Q.ninvoke(StoreEvaluation, 'find', store:store._id).should.eventually.be.like []
    it 'deleted the store from the user list of stores', ->
      User.findByEmail(userSeller.email)
      .then (user) -> user.stores.should.be.like []
