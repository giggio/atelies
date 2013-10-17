require './support/_specHelper'
Store                     = require '../../app/models/store'
Product                   = require '../../app/models/product'
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
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.setFieldsAs otherStore, ->
              page.clickUpdateStoreButton done
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
        expect(store.urlFacebook).to.be.undefined
        expect(store.urlTwitter).to.be.undefined
        expect(store.phoneNumber).to.equal otherStore.phoneNumber
        expect(store.city).to.equal otherStore.city
        expect(store.state).to.equal otherStore.state
        expect(store.zip).to.equal otherStore.zip
        expect(store.otherUrl).to.equal otherStore.otherUrl
        done()
    it 'kept the store to the user', (done) ->
      User.findById userSeller.id, (err, user) ->
        return done err if err
        user.stores.length.should.equal 1
        done()
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin/store/#{otherStore.slug}"
        done()

  describe 'updates to use pagseguro', (done) ->
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
              page.setPagseguroValuesAs email: 'pagseguro@a.com', token: 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA', ->
                page.clickConfirmSetPagseguroButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin/store/#{exampleStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated the store and set pagseguro', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        store.pmtGateways.pagseguro.email.should.equal 'pagseguro@a.com'
        store.pmtGateways.pagseguro.token.should.equal 'FFFFFDAFADSFIUADSKFLDSJALA9D0CAA'
        done()

  describe 'does not update a store to use pagseguro if information is missing', (done) ->
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
              page.setPagseguroValuesAs email: '', token: '', ->
                page.clickConfirmSetPagseguroButton done
    it 'is at the store manage page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin/manageStore/#{exampleStore._id}"
        done()
    it 'does not show store updated message', (done) ->
      page.hasMessage (itDoes) ->
        itDoes.should.be.false
        done()
    it 'shows error messages', (done) ->
      page.pagseguroEmailErrorMsg (emailMsg) ->
        emailMsg.should.equal "O e-mail deve existir e ser válido."
        page.pagseguroTokenErrorMsg (tokenMsg) ->
          tokenMsg.should.equal 'O token do PagSeguro é obrigatório e deve possuir 32 caracteres.'
          done()
    it 'did not update the store and set pagseguro', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store.pmtGateways.pagseguro.email).to.be.undefined
        expect(store.pmtGateways.pagseguro.token).to.be.undefined
        done()

  describe 'updates to do not use pagseguro', ->
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
        url.should.equal "http://localhost:8000/admin/store/#{exampleStore.slug}"
        done()
    it 'shows store updated message', (done) ->
      page.message (msg) ->
        msg.endsWith("Loja atualizada com sucesso").should.be.true
        done()
    it 'updated the store and unset pagseguro', (done) ->
      Store.findBySlug exampleStore.slug, (error, store) ->
        return done error if error
        expect(store.pmtGateways.pagseguro.email).to.be.undefined
        expect(store.pmtGateways.pagseguro.token).to.be.undefined
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
            emptyStore.email = "bla"
            emptyStore.otherUrl = "def"
            page.setFieldsAs emptyStore, ->
              page.clickUpdateStoreButton done
    it 'is at the store manage page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin/manageStore/#{exampleStore._id}"
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
        msgs.zip.should.equal "Informe o CEP no formato 99999-999."
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
        expect(store.urlFacebook).to.equal exampleStore.urlFacebook
        expect(store.urlTwitter).to.equal exampleStore.urlTwitter
        expect(store.phoneNumber).to.equal exampleStore.phoneNumber
        expect(store.city).to.equal exampleStore.city
        expect(store.state).to.equal exampleStore.state
        expect(store.zip).to.equal exampleStore.zip
        expect(store.otherUrl).to.equal exampleStore.otherUrl
        done()

  describe 'updating a store keeps products connected to store', (done) ->
    otherName = otherSlug = null
    before (done) ->
      otherName = "My Super Cool Store"
      otherSlug = "my_super_cool_store"
      cleanDB (error) ->
        return done error if error
        exampleStore = generator.store.a()
        exampleStore.save()
        product = generator.product.a()
        product.save()
        userSeller = generator.user.c()
        userSeller.save()
        userSeller.stores.push exampleStore
        otherStore = generator.store.d().toJSON()
        page.loginFor userSeller._id, ->
          page.visit exampleStore._id.toString(), ->
            page.setName otherName
            page.clickUpdateStoreButton done
    it 'is at the admin store page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/admin/store/#{otherSlug}"
        done()
    it 'updated the store name and slug', (done) ->
      Store.find (error, stores) ->
        return done error if error
        stores.length.should.equal 1
        store = stores[0]
        store.name.should.equal otherName
        store.slug.should.equal otherSlug
        done()
    it 'updated the product name and slug', (done) ->
      Product.find (error, products) ->
        return done error if error?
        products.length.should.equal 1
        product = products[0]
        product.storeSlug.should.to.equal otherSlug
        product.storeName.should.to.equal otherName
        done()
