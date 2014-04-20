require './support/_specHelper'
Store                 = require '../../app/models/store'
Product               = require '../../app/models/product'
ProductComment        = require '../../app/models/productComment'
StoreProductPage      = require './support/pages/storeProductPage'
md5                   = require("blueimp-md5").md5
Postman               = require '../../app/models/postman'
Q                     = require 'q'

describe 'Store product page', ->
  page = store = product1 = null
  before ->
    page = new StoreProductPage()
    whenServerLoaded()
  describe 'regular product', ->
    before ->
      cleanDB().then ->
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        page.visit "store_1", "name_1"
    it 'should show the product info', ->
      page.product().then (product) ->
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
        page.storeNameHeaderExists().should.eventually.be.false

  describe 'store without banner', ->
    before ->
      cleanDB().then ->
        store = generator.store.b()
        store.save()
        product1 = generator.product.c()
        product1.save()
        page.visit "store_2", "name_3"
    it 'does not show the store banner', -> page.storeBannerExists().should.eventually.be.false
    it 'shows store name header', -> page.storeNameHeader().should.become store.name

  describe 'product with no inventory available', ->
    before ->
      cleanDB().then ->
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.inventory = 0
        product1.save()
        page.visit "store_1", "name_1"
    it 'has add cart button disabled', -> page.purchaseItemButtonEnabled().should.eventually.be.false

  describe 'comments', ->
    describe 'showing', ->
      product1 = userCommenting1 = userCommenting2 = body1 = body2 = null
      before ->
        cleanDB()
        .then ->
          store = generator.store.a()
          product1 = generator.product.a()
          Q.all [
            Q.ninvoke store, 'save'
            Q.ninvoke product1, 'save'
          ]
        .then ->
          userCommenting1 = generator.user.a()
          userCommenting2 = generator.user.b()
          body1 = "body1"
          body2 = "body2"
          product1.addComment user: userCommenting1, body: body1
        .then (comment) -> Q.ninvoke comment, 'save'
        .then -> product1.addComment user: userCommenting2, body: body2
        .then (comment) -> Q.ninvoke comment, 'save'
        .then -> page.visit "store_1", "name_1"
      it 'shows comments', ->
        page.comments().then (comments) ->
          comments.length.should.equal 2
          comments[0].userName.should.equal userCommenting1.name
          comments[0].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userCommenting1.email.toLowerCase())}?d=mm&r=pg&s=50"
          comments[0].body.should.equal body1
          comments[1].userName.should.equal userCommenting2.name
          comments[1].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userCommenting2.email.toLowerCase())}?d=mm&r=pg&s=50"
          comments[1].body.should.equal body2
    describe 'creating', ->
      userCommenting = userSeller = body = null
      before ->
        cleanDB().then ->
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
          page.loginFor userCommenting._id
          .then -> page.visit "store_1", "name_1"
          .then -> page.writeComment body
      it 'created the comment on the database', ->
        Q.ninvoke ProductComment, "findByProduct", product1._id
        .then (comments) ->
          comments.length.should.equal 1
          comm = comments[0]
          comm.user.toString().should.equal userCommenting._id.toString()
          comm.date.should.equalDate new Date()
          comm.body.should.equal body
          comm.userName.should.equal userCommenting.name
          comm.userEmail.should.equal userCommenting.email
      it 'displayed the comment', ->
        page.comments().then (comments) ->
          comments.length.should.equal 1
          comments[0].userName.should.equal userCommenting.name
          comments[0].userPicture.should.equal "https://secure.gravatar.com/avatar/#{md5(userCommenting.email.toLowerCase())}?d=mm&r=pg&s=50"
          comments[0].body.should.equal body
      it 'cleared the comment area', -> page.newCommentBodyText().should.become ''
      it 'emailed the store admin', ->
        Postman.sentMails.length.should.equal 1
        mail = Postman.sentMails[0]
        mail.to.should.equal "#{userSeller.name} <#{userSeller.email}>"
        mail.subject.should.equal "Ateliês: O produto #{product1.name} da loja #{store.name} recebeu um comentário"

    describe "can't create if not logged in", ->
      before ->
        cleanDB().then ->
          page.clearCookies()
        .then ->
          Postman.sentMails.length = 0
          store = generator.store.a()
          store.save()
          product1 = generator.product.a()
          product1.save()
          page.visit "store_1", "name_1"
      it "comment text is invisible", -> page.commentBodyIsVisible().should.eventually.be.false
      it 'comment button is invisible', -> page.commentButtonIsVisible().should.eventually.be.false
      it 'has a message stating user must login to comment', -> page.mustLoginToCommentMessageIsVisible().should.eventually.be.true
