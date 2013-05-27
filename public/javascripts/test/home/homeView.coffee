define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
_s = require('underscore.string')
define [
  'jquery'
  'areas/home/views/home'
  '../support/_specHelper'
], ($, HomeView) ->
  homeView = null
  el = $('<div></div>')
  product1 = product2 = products = store1 = store2 = store3 = stores = null
  describe 'HomeView', ->
    before ->
      product1 = generatorc.product.a()
      product2 = generatorc.product.b()
      products = [ product1, product2 ]
      store1 = generatorc.store.a()
      store2 = generatorc.store.b()
      store3 = generatorc.store.c()
      stores = [store1, store2, store3]
      homeView = new HomeView el:el, products: products, stores: stores
      homeView.render()
    it 'should render the products', ->
      expect($('#productsHome', el)).to.be.defined
    it 'should display all the products', ->
      expect($('#productsHome>.carouselHolder', el).length).to.equal products.length
    it 'should display the store name for product 1', ->
      expect($("#product1_store", el).text()).to.equal product1.storeName
    it 'link to the store on product 1', ->
      expect($("#product1_store a", el).attr('href')).to.equal product1.storeSlug
    it 'should display the store name for product 2', ->
      expect($("#product2_store", el).text()).to.equal product2.storeName
    it 'links to the store on product 2', ->
      expect($("#product2_store a", el).attr('href')).to.equal product2.storeSlug
    it 'displays the product name on product 1', ->
      expect($("#product1_name", el).text()).to.equal product1.name
    it 'links to the product page on the product name on product 1', ->
      expect($("#product1 a", el).attr('href')).to.equal "#{product1.storeSlug}##{product1.slug}"
    it 'displays the picture for product 1', ->
      expect($("#product1_picture img", el).attr('src')).to.equal product1.picture
    it 'links to the product page on the picture on product 1', ->
      expect($("#product1_picture", el).attr('href')).to.equal "#{product1.storeSlug}##{product1.slug}"
    it 'shows stores', ->
      $('#storesHome>.store', el).length.should.equal stores.length
    it 'shows store banner', ->
      $('#store1 img', el).attr('src').should.equal store1.flyer
