define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/store/views/product'
  'backbone'
  'areas/store/models/cart'
  'underscore'
  'areas/store/models/product'
], ($, ProductView, Backbone, Cart, _, Product) ->
  product1  = generatorc.product.a()
  product2  = generatorc.product.b()
  store1    = generatorc.store.a()
  store2    = generatorc.store.b()
  productView = null
  el = $('<div></div>')
  describe 'ProductView', ->
    describe 'Store with banner and product with inventory', ->
      before ->
        productView = new ProductView el:el, store: store1, product: new Product product1
        productView.render 'product_1'
      it 'renders the products', ->
        expect($('#product1', el)).to.be.defined
      it 'show the name', ->
        expect($("#product1 #name", el).text()).to.equal product1.name
      it 'shows the picture', ->
        expect($("#product1 #picture", el).attr('src')).to.equal product1.picture
      it 'shows the id', ->
        expect($("#product1 #id", el).text()).to.equal product1._id
      it 'shows the price', ->
        expect($('#product1 #price', el).text()).to.equal product1.price.toString()
      it 'shows the tags', ->
        expect($('#product1 #tags', el).text()).to.equal product1.tags
      it 'shows the description', ->
        expect($('#product1 #description', el).text()).to.equal product1.description
      it 'shows the height', ->
        expect($('#product1 #dimensions #height', el).text()).to.equal product1.height.toString()
      it 'shows the width', ->
        expect($('#product1 #dimensions #width', el).text()).to.equal product1.width.toString()
      it 'shows the depth', ->
        expect($('#product1 #dimensions #depth', el).text()).to.equal product1.depth.toString()
      it 'shows the weight', ->
        expect($('#product1 #weight', el).text()).to.equal product1.weight.toString()
      it 'shows the inventory', ->
        expect($('#product1 #inventory', el).text()).to.equal '30 itens'
      describe 'Store details', ->
        it 'shows the store name', ->
          expect($('#storeName', el).text()).to.equal store1.name
        it 'shows phone number', ->
          expect($('#storePhoneNumber', el).text()).to.equal store1.phoneNumber
        it 'shows City', ->
          expect($('#storeCity', el).text()).to.equal store1.city
        it 'shows State', ->
          expect($('#storeState', el).text()).to.equal store1.state
        it 'shows other store url', ->
          expect($('#storeOtherUrl', el).text()).to.equal store1.otherUrl
        it 'does not show the store name header', ->
          expect($('#storeNameHeader', el).length).to.equal 0
        it 'shows store banner', ->
          expect($('#storeBanner', el).attr('src')).to.equal store1.banner
    describe 'Store without banner and product without inventory', ->
      before ->
        productView = new ProductView el:el, store: store2, product: new Product product2
        productView.render 'product_2'
      it 'shows there is no inventory/made on demand', ->
        expect($('#product2 #inventory', el).text()).to.equal 'Feito sob encomenda'
      it 'shows store name header', ->
        expect($('#storeNameHeader', el).text()).to.equal store2.name
      it 'does not show the store banner', ->
        expect($('#storeBanner', el).length).to.equal 0
    describe 'Purchasing an item', ->
      spy = null
      before ->
        Cart.get().clear()
        spy = sinon.spy Backbone.history, "navigate"
        productView = new ProductView el:el, store: store2, product: new Product product2
        productView.render 'product_2'
        productView.purchase()
      it 'adds an item to the cart', ->
        expect(_.findWhere(Cart.get(store2.slug).items(), _id: product2._id).id).not.to.be.null
      it 'navigated', ->
        expect(spy).to.have.been.calledWith '#cart', trigger:true

