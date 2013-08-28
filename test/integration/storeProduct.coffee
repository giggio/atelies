require './support/_specHelper'
Store                 = require '../../app/models/store'
Product               = require '../../app/models/product'
StoreProductPage      = require './support/pages/storeProductPage'
md5                   = require("blueimp-md5").md5

describe 'Store product page', ->
  page = store = product1 = null
  before (done) ->
    page = new StoreProductPage()
    whenServerLoaded done
  after (done) -> page.closeBrowser done
  describe 'regular product', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        page.visit "store_1", "name_1", done
    it 'should show the product info', (done) ->
      page.product (product) ->
        product.name.should.equal product1.name
        product.price.should.equal product1.price.toString()
        product.tags.should.be.like ['abc', 'def']
        product.description.should.equal product1.description
        product.height.should.equal product1.dimensions.height.toString()
        product.width.should.equal product1.dimensions.width.toString()
        product.depth.should.equal product1.dimensions.depth.toString()
        product.weight.should.equal product1.weight.toString()
        product.inventory.should.equal '30 itens'
        product.storeName.should.equal store.name
        product.storePhoneNumber.should.equal store.phoneNumber
        product.storeCity.should.equal store.city
        product.storeState.should.equal store.state
        product.storeOtherUrl.should.equal store.otherUrl
        product.banner.should.equal store.banner
        product.picture.should.equal product1.picture
        page.storeNameHeaderExists (itDoes) ->
          itDoes.should.be.false
          done()

  describe 'store without banner', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.b()
        store.save()
        product1 = generator.product.c()
        product1.save()
        page.visit "store_2", "name_3", done
    it 'does not show the store banner', (done) ->
      page.storeBannerExists (itDoes) -> itDoes.should.be.false;done()
    it 'shows store name header', (done) ->
      page.storeNameHeader (header) ->
        header.should.equal store.name
        done()

  describe 'product with no inventory available', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.inventory = 0
        product1.save()
        page.visit "store_1", "name_1", done
    it 'has add cart button disabled', (done) ->
      page.purchaseItemButtonEnabled (itIs) ->
        itIs.should.be.false
        done()

  describe 'comments', ->
    describe 'showing', ->
      userCommenting1 = userCommenting2 = title1 = title2 = body1 = body2 = null
      before (done) ->
        cleanDB (error) ->
          return done error if error
          store = generator.store.a()
          store.save()
          product1 = generator.product.a()
          userCommenting1 = generator.user.a()
          userCommenting2 = generator.user.b()
          body1 = "body1"
          body2 = "body2"
          title1 = "body1"
          title2 = "body2"
          product1.addComment user: userCommenting1, title: title1, body: body1
          product1.addComment user: userCommenting2, title: title2, body: body2
          product1.save()
          page.visit "store_1", "name_1", done
      it 'shows comments', (done) ->
        page.comments (comments) ->
          comments.length.should.equal 2
          comments[0].userName.should.equal userCommenting1.name
          comments[0].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userCommenting1.email.toLowerCase())}?d=mm&r=pg&s=50"
          comments[0].body.should.equal body1
          comments[1].userName.should.equal userCommenting2.name
          comments[1].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userCommenting2.email.toLowerCase())}?d=mm&r=pg&s=50"
          comments[1].body.should.equal body2
          done()
