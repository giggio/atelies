define [
  'jquery'
  'areas/admin/views/manageStore'
], ($, ManageStoreView) ->
  el = $('<div></div>')
  describe 'ManageStoreView', ->
    describe 'Valid Store gets created', ->
      url = products = store = manageStoreView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        store = generator.store.a()
        product1 = generator.product.a()
        product2 = generator.product.b()
        products = [product1, product2]
        global.adminStoresBootstrapModel = stores:[store]
        spyOn($, "ajax").andCallFake (opt) ->
          url  = opt.url
          opt.success products
        manageStoreView = new ManageStoreView el:el, storeSlug: store.slug
        manageStoreView.render()
      it 'shows store', ->
        expect(manageStoreView.$("#name").text()).toBe store.name
      it 'shows products', ->
        expect($("#products > tbody > tr", el).length).toBe products.length
      it 'should go to the products url', ->
        expect(url).toBe "/#{store.slug}"
