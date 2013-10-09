require './support/_specHelper'
Store                     = require '../../app/models/store'
User                      = require '../../app/models/user'
AdminManageStorePage      = require './support/pages/adminManageStorePage'
AmazonFileUploader        = require '../../app/helpers/amazonFileUploader'
path                      = require "path"

describe 'Admin create store page', ->
  page = exampleStore = userSeller = null
  after (done) -> page.closeBrowser done
  before (done) ->
    page = new AdminManageStorePage()
    whenServerLoaded done
  describe 'creates a store', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        page.loginFor userSeller._id, ->
          page.visit ->
            page.setFieldsAs exampleStore, ->
              page.clickUpdateStoreButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
        done()
    it 'shows store created message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja criada com sucesso").should.be.true
        done()
    it 'created a new store with correct information', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
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
        done()
    it 'added the store to the user', (done) ->
      User.findById userSeller.id, (err, user) ->
        return done err if err
        user.stores.length.should.equal 1
        done()

  describe 'does not create a store (missing or wrong info)', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.empty()
        page.loginFor userSeller._id, ->
          page.visit ->
            exampleStore.email = "bla"
            exampleStore.zip = 'cep'
            exampleStore.otherUrl = "def"
            page.setFieldsAs exampleStore, ->
              page.clickUpdateStoreButton done
    it 'is at the store create page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#createStore"
        done()
    it 'does not show store created message', (done) ->
      page.hasMessage (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows validation messages', (done) ->
      page.errorMessagesIn "#manageStoreBlock", (msgs) ->
        msgs.name.should.equal "Informe o nome da loja."
        msgs.email.should.equal "O e-mail deve ser válido."
        msgs.city.should.equal "Informe a cidade."
        msgs.zip.should.equal "Informe o CEP no formato 99999-999."
        msgs.otherUrl.should.equal "Informe um link válido para o outro site, começando com http ou https."
        done()
    it 'did not create a store with missing info', (done) ->
      Store.find (error, stores) ->
        return done error if error
        expect(stores.length).to.equal 0
        done()
  describe 'does not create a store with a existing name', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        exampleStore.save()
        page.loginFor userSeller._id, ->
          page.visit ->
            page.setFieldsAs exampleStore, ->
              page.clickUpdateStoreButton done
    it 'is at the store create page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#createStore"
        done()
    it 'does not show store created message', (done) ->
      page.hasMessage (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows store name already exists', (done) ->
      page.storeNameExistsModalVisible (itDoes) ->
        itDoes.should.be.true
        done()

  describe 'creates store with picture upload', (done) ->
    uploadedRegexMatch = /^https:\/\/s3\.amazonaws\.com\/dryrun\/store_1\/store\/\d+\.png$/
    before (done) ->
      AmazonFileUploader.filesUploaded.length = 0
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        page.loginFor userSeller._id, ->
          page.visit ->
            page.setFieldsAs exampleStore, ->
              bannerPath = path.join __dirname, 'support', 'images', '200x200.png'
              flyerPath = path.join __dirname, 'support', 'images', '600x600.png'
              homePageImagePath = path.join __dirname, 'support', 'images', '700x700.png'
              page.setPictureFiles bannerPath, flyerPath, homePageImagePath, ->
                page.clickUpdateStoreButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
        done()
    it 'shows store created message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja criada com sucesso").should.be.true
        done()
    it 'tried to upload the file', ->
      AmazonFileUploader.filesUploaded[0].should.match uploadedRegexMatch
      AmazonFileUploader.filesUploaded[1].should.match uploadedRegexMatch
      AmazonFileUploader.filesUploaded[2].should.match uploadedRegexMatch
    it 'created a new store with correct information and file uploads', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
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
        done()
    it 'added the store to the user', (done) ->
      User.findById userSeller.id, (err, user) ->
        return done err if err
        user.stores.length.should.equal 1
        done()
