store1 = generator.store.a()
store2 = generator.store.b()
stores = [store1, store2]
define 'adminStoresData', -> stores
define [
  'jquery'
  'areas/admin/views/admin'
], ($, AdminView) ->
  el = $('<div></div>')
  describe 'AdminView', ->
    describe 'With stores', ->
      store1 = generator.store.a()
      store2 = generator.store.b()
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        createStoreView = new AdminView el:el, stores: [store1, store2]
        createStoreView.render()
      it 'shows create store link', ->
        expect($("#createStore", el).val()).toBe "Crie uma nova loja"
      it 'shows the stores being managed', ->
        expect($("#stores > tbody > tr", el).length).toBe 2
        expect($("#stores > tbody > tr:first-child > td:first-child", el).text()).toBe store1.name
        expect($("#stores > tbody > tr:first-child > td:first-child > a", el).attr('href')).toBe "#manageStore/#{store1.slug}"
        expect($("#stores > tbody > tr:nth-child(2) > td:first-child", el).text()).toBe store2.name
        expect($("#stores > tbody > tr:nth-child(2) > td:first-child > a", el).attr('href')).toBe "#manageStore/#{store2.slug}"
    describe 'Without stores', ->
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        createStoreView = new AdminView el:el, stores: []
        createStoreView.render()
      it 'does not show the stores table', ->
        expect($("#stores", el).length).toBe 0
