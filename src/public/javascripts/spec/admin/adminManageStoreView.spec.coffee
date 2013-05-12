define [
  'jquery'
  'areas/admin/views/manageStore'
  'areas/admin/models/products'
], ($, ManageStoreView, Products) ->
  el = $('<div></div>')
  describe 'ManageStoreView', ->
    describe 'Valid Store gets created', ->
      products = store = manageStoreView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        store = generator.store.a()
        product1 = generator.product.a()
        product2 = generator.product.b()
        products = [product1, product2]
        productsModel = new Products products, storeSlug: store.slug
        manageStoreView = new ManageStoreView el:el, store: store, products: productsModel
        manageStoreView.render()
      it 'shows store', ->
        expect(manageStoreView.$("#name").text()).toBe store.name
      it 'shows products', ->
        expect($("#products > tbody > tr", el).length).toBe products.length
