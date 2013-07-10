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
  product3  = generatorc.product.a()
  product3.inventory = 0
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
        expect($('#product', el)).to.be.defined
      it 'show the name', ->
        expect($("#product #name", el).text()).to.equal product1.name
      it 'shows the picture', ->
        expect($("#product #picture", el).attr('src')).to.equal product1.picture
      it 'shows the id', ->
        expect($("#product", el).attr('data-id')).to.equal product1._id
      it 'shows the price', ->
        expect($('#product #price', el).text()).to.equal product1.price.toString()
      it 'shows the tags', ->
        $('#product .tag', el).text().should.equal product1.tags.split(', ').join ''
      it 'shows the description', ->
        expect($('#product #description', el).text()).to.equal product1.description
      it 'shows the height', ->
        expect($('#product #dimensions #height', el).text()).to.equal product1.height.toString()
      it 'shows the width', ->
        expect($('#product #dimensions #width', el).text()).to.equal product1.width.toString()
      it 'shows the depth', ->
        expect($('#product #dimensions #depth', el).text()).to.equal product1.depth.toString()
      it 'shows the weight', ->
        expect($('#product #weight', el).text()).to.equal product1.weight.toString()
      it 'shows the inventory', ->
        expect($('#product #inventory', el).text()).to.equal '30 itens'
      it 'enabled add to cart button', ->
        expect($('#purchaseItem', el).attr('disabled')).to.be.undefined
    describe 'product without inventory', ->
      before ->
        productView = new ProductView el:el, store: store2, product: new Product product2
        productView.render 'product_2'
      it 'shows there is no inventory/made on demand', ->
        expect($('#product #inventory', el).text()).to.equal 'Feito sob encomenda'
      it 'enabled add to cart button', ->
        expect($('#purchaseItem', el).attr('disabled')).to.be.undefined
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
    describe 'product with inventory but none available', ->
      before ->
        productView = new ProductView el:el, store: store1, product: new Product product3
        productView.render 'product_1'
      it 'disable add to cart button', ->
        $('#purchaseItem', el).attr('disabled').should.equal 'disabled'
