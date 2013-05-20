define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/manageStore'
  'areas/admin/models/products'
], ($, ManageStoreView, Products) ->
  el = $('<div></div>')
  describe 'ManageStoreView', ->
    describe 'Valid Store gets created', ->
      products = store = manageStoreView = null
      before ->
        store = generatorc.store.a()
        product1 = generatorc.product.a()
        product2 = generatorc.product.b()
        products = [product1, product2]
        productsModel = new Products products, storeSlug: store.slug
        manageStoreView = new ManageStoreView el:el, store: store, products: productsModel
        manageStoreView.render()
      it 'shows store', ->
        expect(manageStoreView.$("#name").text()).to.equal store.name
      it 'shows products', ->
        expect($("#products > tbody > tr", el).length).to.equal products.length
