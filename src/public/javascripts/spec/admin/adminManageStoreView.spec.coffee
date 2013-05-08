define [
  'jquery'
  'areas/admin/views/manageStore'
], ($, ManageStoreView) ->
  el = $('<div></div>')
  describe 'ManageStoreView', ->
    describe 'Valid Store gets created', ->
      store = manageStoreView = null
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        store = generator.store.a()
        global.adminStoresBootstrapModel = stores:[store]
        manageStoreView = new ManageStoreView el:el, storeSlug: store.slug
        manageStoreView.render()
      it 'shows store', ->
        expect(manageStoreView.$("#name").text()).toBe store.name
