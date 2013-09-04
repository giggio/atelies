require './support/_specHelper'
Store                 = require '../../app/models/store'
Product               = require '../../app/models/product'
ProductComment        = require '../../app/models/productComment'
StoreProductPage      = require './support/pages/storeProductPage'
md5                   = require("blueimp-md5").md5
Postman               = require '../../app/models/postman'

describe 'Store product page', ->
  page = store = product1 = null
  before (done) ->
    page = new StoreProductPage()
    whenServerLoaded done
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
      userCommenting1 = userCommenting2 = body1 = body2 = null
      before (done) ->
        cleanDB (error) ->
          return done error if error
          store = generator.store.a()
          store.save()
          product1 = generator.product.a()
          product1.save()
          userCommenting1 = generator.user.a()
          userCommenting2 = generator.user.b()
          body1 = "body1"
          body2 = "body2"
          product1.addComment user: userCommenting1, body: body1, (err, comment) =>
            comment.save()
            product1.addComment user: userCommenting2, body: body2, (err, comment) =>
              comment.save()
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
    describe 'creating', ->
      userCommenting = userSeller = body = null
      before (done) ->
        cleanDB (error) ->
          return done error if error
          Postman.sentMails.length = 0
          store = generator.store.a()
          store.save()
          userSeller = generator.user.c()
          userSeller.stores.push store
          userSeller.save()
          product1 = generator.product.a()
          userCommenting = generator.user.a()
          userCommenting.save()
          product1.save()
          body = "body1"
          page.loginFor userCommenting._id, ->
            page.visit "store_1", "name_1", ->
              page.writeComment body, done
      it 'created the comment on the database', (done) ->
        ProductComment.findByProduct product1._id, (err, comments) ->
          comments.length.should.equal 1
          comm = comments[0]
          comm.user.toString().should.equal userCommenting._id.toString()
          comm.date.should.equalDate new Date()
          comm.body.should.equal body
          comm.userName.should.equal userCommenting.name
          comm.userEmail.should.equal userCommenting.email
          done()
      it 'displayed the comment', (done) ->
        page.comments (comments) ->
          comments.length.should.equal 1
          comments[0].userName.should.equal userCommenting.name
          comments[0].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userCommenting.email.toLowerCase())}?d=mm&r=pg&s=50"
          comments[0].body.should.equal body
          done()
      it 'cleared the comment area', (done) ->
        page.newCommentBodyText (t) ->
          t.should.equal ''
          done()
      it 'emailed the store admin', ->
        Postman.sentMails.length.should.equal 1
        mail = Postman.sentMails[0]
        mail.to.should.equal "'#{userSeller.name}' <#{userSeller.email}>"
        mail.subject.should.equal "Ateliês: O produto #{product1.name} da loja #{store.name} recebeu um comentário"

    describe "can't create if not logged in", ->
      before (done) ->
        cleanDB (error) ->
          return done error if error
          page.clearCookies =>
            Postman.sentMails.length = 0
            store = generator.store.a()
            store.save()
            product1 = generator.product.a()
            product1.save()
            page.visit "store_1", "name_1", done
      it "comment text is invisible", (done) ->
        page.commentBodyIsVisible (itIs) ->
          itIs.should.be.false
          done()
      it 'comment button is invisible', (done) ->
        page.commentButtonIsVisible (itIs) ->
          itIs.should.be.false
          done()
      it 'has a message stating user must login to comment', (done) ->
        page.mustLoginToCommentMessageIsVisible (itIs) ->
          itIs.should.be.true
          done()
