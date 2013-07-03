require './support/_specHelper'
Store                     = require '../../app/models/store'
User                      = require '../../app/models/user'
AdminManageStorePage      = require './support/pages/adminManageStorePage'

describe 'Admin manage store page', ->
  page = exampleStore = otherStore = userSeller = null
  after (done) -> page.closeBrowser done
  before (done) ->
    page = new AdminManageStorePage()
    whenServerLoaded done
  describe 'updates a store', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.a()
        exampleStore.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        otherStore = generator.store.d().toJSON()
        delete otherStore.autoCalculateShipping
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.setFieldsAs otherStore, ->
              page.clickUpdateStoreButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{otherStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated a new store with correct information', (done) ->
      Store.find (error, stores) ->
        return done error if error
        stores.length.should.equal 1
        store = stores[0]
        expect(store).not.to.be.null
        expect(store.slug).to.equal otherStore.slug
        expect(store.name).to.equal otherStore.name
        expect(store.email).to.equal otherStore.email
        expect(store.description).to.equal otherStore.description
        expect(store.homePageDescription).to.equal otherStore.homePageDescription
        expect(store.homePageImage).to.equal otherStore.homePageImage
        expect(store.urlFacebook).to.equal otherStore.urlFacebook
        expect(store.urlTwitter).to.equal otherStore.urlTwitter
        expect(store.phoneNumber).to.equal otherStore.phoneNumber
        expect(store.city).to.equal otherStore.city
        expect(store.state).to.equal otherStore.state
        expect(store.zip).to.equal otherStore.zip
        expect(store.otherUrl).to.equal otherStore.otherUrl
        expect(store.banner).to.equal otherStore.banner
        expect(store.flyer).to.equal otherStore.flyer
        expect(store.autoCalculateShipping).to.equal true
        done()
    it 'kept the store to the user', (done) ->
      User.findById userSeller.id, (err, user) ->
        return done err if err
        user.stores.length.should.equal 1
        done()

  describe 'does not update a store to autocalculate shipping if the store has products without shipping info', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.d()
        exampleStore.save()
        product = generator.product.a()
        product.storeName = exampleStore.name
        product.storeSlug = exampleStore.slug
        product.shipping = undefined
        product.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.clickSetAutoCalculateShippingButton ->
              page.clickConfirmSetAutoCalculateShippingButton done
    it 'is at the store manage page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#manageStore/#{exampleStore._id}"
        done()
    it 'does not show store updated message', (done) ->
      page.hasMessage (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows error message', (done) ->
      page.autoCalculateShippingErrorMsg (msg) ->
        msg.should.equal "O cálculo de postagem não foi ligado. Verifique se todos os seus produtos possuem informações de postagem e tente novamente."
        done()
    it 'did not update the store and set auto calculate shipping', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store.autoCalculateShipping).to.equal false
        done()

  describe 'updates a store to autocalculate shipping if the store has products with shipping info', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.d()
        exampleStore.save()
        product = generator.product.a()
        product.storeName = exampleStore.name
        product.storeSlug = exampleStore.slug
        product.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.clickSetAutoCalculateShippingButton ->
              page.clickConfirmSetAutoCalculateShippingButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated the store and set auto calculate shipping', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store.autoCalculateShipping).to.equal true
        done()

  describe 'updates a store to turn off autocalculate shipping', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.a()
        exampleStore.save()
        product = generator.product.a()
        product.storeName = exampleStore.name
        product.storeSlug = exampleStore.slug
        product.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.clickUnsetAutoCalculateShippingButton ->
              page.clickConfirmUnsetAutoCalculateShippingButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated the store and set auto calculate shipping', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store.autoCalculateShipping).to.equal false
        done()

  describe 'updates a store to use pagseguro', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.c()
        exampleStore.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.clickSetPagseguroButton ->
              page.clickConfirmSetPagseguroButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated the store and set pagseguro', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store.pmtGateways).to.be.like ['pagseguro']
        done()

  describe 'updates a store to do not use pagseguro', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.a()
        exampleStore.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.clickUnsetPagseguroButton ->
              page.clickConfirmUnsetPagseguroButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#store/#{exampleStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated the store and set pagseguro', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        store.pmtGateways.should.be.empty
        done()

  describe 'does not update a store (missing or wrong info)', (done) ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        userSeller = generator.user.c()
        userSeller.save()
        exampleStore = generator.store.a()
        exampleStore.save()
        emptyStore = generator.store.empty()
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), (error) ->
            return done error if error
            emptyStore.banner = "abc"
            emptyStore.email = "bla"
            emptyStore.flyer = "mng"
            emptyStore.otherUrl = "def"
            page.setFieldsAs emptyStore, ->
              page.clickUpdateStoreButton done
    it 'is at the store manage page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin#manageStore/#{exampleStore._id}"
        done()
    it 'does not show store updated message', (done) ->
      page.hasMessage (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows validation messages', (done) ->
      page.errorMessagesIn "#manageStoreBlock", (msgs) ->
        msgs.name.should.equal "Informe o nome da loja."
        msgs.email.should.equal "O e-mail deve ser válido."
        msgs.city.should.equal "Informe a cidade."
        msgs.zip.should.equal "Informe o CEP."
        msgs.banner.should.equal "Informe um link válido para o banner, começando com http ou https."
        msgs.flyer.should.equal "Informe um link válido para o flyer, começando com http ou https."
        msgs.otherUrl.should.equal "Informe um link válido para o outro site, começando com http ou https."
        done()
    it 'did not update the store with wrong info', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store).not.to.be.null
        expect(store.slug).to.equal exampleStore.slug
        expect(store.name).to.equal exampleStore.name
        expect(store.email).to.equal exampleStore.email
        expect(store.description).to.equal exampleStore.description
        expect(store.homePageDescription).to.equal exampleStore.homePageDescription
        expect(store.homePageImage).to.equal exampleStore.homePageImage
        expect(store.urlFacebook).to.equal exampleStore.urlFacebook
        expect(store.urlTwitter).to.equal exampleStore.urlTwitter
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.zip).to.equal exampleStore.zip
        expect(store.otherUrl).to.equal exampleStore.otherUrl
        expect(store.banner).to.equal exampleStore.banner
        expect(store.flyer).to.equal exampleStore.flyer
        expect(store.autoCalculateShipping).to.equal exampleStore.autoCalculateShipping
        done()
