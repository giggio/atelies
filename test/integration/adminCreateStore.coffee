require './support/_specHelper'
Store                     = require '../../app/models/store'
User                      = require '../../app/models/user'
AdminManageStorePage      = require './support/pages/adminManageStorePage'
AmazonFileUploader        = require '../../app/helpers/amazonFileUploader'
path                      = require "path"
Q                         = require 'q'

describe 'Admin create store page', ->
  page = exampleStore = userSeller = null
  before ->
    page = new AdminManageStorePage()
    whenServerLoaded()
  describe 'creates a store', ->
    before ->
      cleanDB().then ->
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        page.loginFor userSeller._id
      .then page.visit
      .then -> page.setFieldsAs exampleStore
      .then page.clickUpdateStoreButton
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{exampleStore.slug}"
    it 'shows store created message', -> page.message().then (msg) -> msg.endsWith("Loja criada com sucesso").should.be.true
    it 'created a new store with correct information', ->
      Q.ninvoke(Store, "findBySlug", exampleStore.slug).then (store) ->
        expect(store).not.to.be.null
        expect(store.slug).to.equal exampleStore.slug
        expect(store.name).to.equal exampleStore.name
        expect(store.email).to.equal exampleStore.email
        expect(store.description).to.equal exampleStore.description
        expect(store.homePageDescription).to.equal exampleStore.homePageDescription
        expect(store.urlFacebook).to.equal exampleStore.urlFacebook
        expect(store.urlTwitter).to.equal exampleStore.urlTwitter
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.zip).to.equal exampleStore.zip
        expect(store.otherUrl).to.equal exampleStore.otherUrl
        expect(store.pmtGateways.pagseguro.email).to.be.equal exampleStore.pmtGateways.pagseguro.email
        expect(store.pmtGateways.pagseguro.token).to.be.equal exampleStore.pmtGateways.pagseguro.token
    it 'added the store to the user', -> Q.ninvoke(User, "findById", userSeller.id).then (user) -> user.stores.length.should.equal 1

  describe 'does not create a store (missing or wrong info)', ->
    before ->
      cleanDB().then ->
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.empty()
        page.loginFor userSeller._id
      .then page.visit
      .then ->
        exampleStore.email = "bla"
        exampleStore.zip = 'cep'
        exampleStore.otherUrl = "def"
      .then -> page.setFieldsAs exampleStore
      .then page.clickUpdateStoreButton
    it 'is at the store create page', -> page.currentUrl().should.become "http://localhost:8000/admin/createStore"
    it 'does not show store created message', -> page.hasMessage().should.eventually.be.false
    it 'shows validation messages', ->
      page.errorMessagesIn("#manageStoreBlock").then (msgs) ->
        msgs.name.should.equal "Informe o nome da loja."
        msgs.email.should.equal "O e-mail deve ser válido."
        msgs.city.should.equal "Informe a cidade."
        msgs.zip.should.equal "Informe o CEP no formato 99999-999."
        msgs.otherUrl.should.equal "Informe um link válido para o outro site, começando com http ou https."
    it 'did not create a store with missing info', -> Q.ninvoke(Store, "find").then (stores) -> stores.length.should.equal 0
  describe 'does not create a store with a existing name', ->
    before ->
      cleanDB().then ->
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        exampleStore.save()
        page.loginFor userSeller._id
      .then page.visit
      .then -> page.setFieldsAs exampleStore
      .then page.clickUpdateStoreButton
    it 'is at the store create page', -> page.currentUrl().should.become "http://localhost:8000/admin/createStore"
    it 'does not show store created message', -> page.hasMessage().should.eventually.be.false
    it 'shows store name already exists', -> page.storeNameExistsModalVisible().should.eventually.be.true

  describe 'creates store with picture upload', ->
    uploadedRegexMatch = /^https:\/\/s3\.amazonaws\.com\/dryrun\/store_1\/store\/\d+\.png$/
    before ->
      AmazonFileUploader.filesUploaded.length = 0
      cleanDB().then ->
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
      .then -> page.loginFor userSeller._id
      .then page.visit
      .then -> page.setFieldsAs exampleStore
      .then ->
        bannerPath = path.join __dirname, 'support', 'images', '200x200.png'
        flyerPath = path.join __dirname, 'support', 'images', '800x800.png'
        homePageImagePath = path.join __dirname, 'support', 'images', '700x700.png'
        page.setPictureFiles bannerPath, flyerPath, homePageImagePath
      .then page.clickUpdateStoreButton
    it 'is at the admin store page', -> page.currentUrl().should.become "http://localhost:8000/admin/store/#{exampleStore.slug}"
    it 'shows store created message', -> page.message().then (msg) -> msg.endsWith("Loja criada com sucesso").should.be.true
    it 'tried to upload the file', ->
      AmazonFileUploader.filesUploaded[0].should.match uploadedRegexMatch
      AmazonFileUploader.filesUploaded[1].should.match uploadedRegexMatch
      AmazonFileUploader.filesUploaded[2].should.match uploadedRegexMatch
    it 'created a new store with correct information and file uploads', ->
      Q.ninvoke(Store, "findBySlug", exampleStore.slug).then (store) ->
        expect(store).not.to.be.null
        store.homePageImage.should.match uploadedRegexMatch
        store.flyer.should.match uploadedRegexMatch
        store.banner.should.match uploadedRegexMatch
        expect(store.slug).to.equal exampleStore.slug
        expect(store.name).to.equal exampleStore.name
        expect(store.email).to.equal exampleStore.email
        expect(store.description).to.equal exampleStore.description
        expect(store.homePageDescription).to.equal exampleStore.homePageDescription
        expect(store.urlFacebook).to.equal exampleStore.urlFacebook
        expect(store.urlTwitter).to.equal exampleStore.urlTwitter
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.zip).to.equal exampleStore.zip
        expect(store.otherUrl).to.equal exampleStore.otherUrl
        expect(store.pmtGateways.pagseguro.email).to.be.equal exampleStore.pmtGateways.pagseguro.email
        expect(store.pmtGateways.pagseguro.token).to.be.equal exampleStore.pmtGateways.pagseguro.token
    it 'added the store to the user', -> Q.ninvoke(User, "findById", userSeller.id).then (user) -> user.stores.length.should.equal 1
