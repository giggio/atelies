define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/store'
  'areas/admin/models/products'
], ($, StoreView, Products) ->
  el = $('<div></div>')
  describe 'StoreView', ->
    describe 'Valid Store gets created', ->
      products = store = storeView = null
      before ->
        store = generatorc.store.a()
        product1 = generatorc.product.a()
        product2 = generatorc.product.b()
        products = [product1, product2]
        productsModel = new Products products, storeSlug: store.slug
        storeView = new StoreView el:el, store: store, products: productsModel
        storeView.render()
      it 'shows store', ->
        expect(storeView.$("#name").text()).to.equal store.name
      it 'shows products', ->
        expect($("#products .product", el).length).to.equal products.length
