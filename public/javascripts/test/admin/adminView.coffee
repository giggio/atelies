define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/admin'
], ($, AdminView) ->
  el = $('<div></div>')
  describe 'AdminView', ->
    describe 'With stores', ->
      store1 = generatorc.store.a()
      store2 = generatorc.store.b()
      before ->
        store1 = generatorc.store.a()
        store2 = generatorc.store.b()
        stores = [store1, store2]
        adminView = new AdminView el:el, stores: stores
        adminView.render()
      it 'shows create store link', ->
        expect($("#createStore", el).val()).to.equal "Crie uma nova loja"
      it 'shows the stores being managed', ->
        expect($("#stores .store", el).length).to.equal 2
        expect($("#stores [data-id='#{store1._id}'] .name", el).text().trim()).to.equal store1.name
        expect($("#stores [data-id='#{store1._id}'] .link", el).attr('href')).to.equal "store/#{store1.slug}"
        expect($("#stores [data-id='#{store2._id}'] .name", el).text().trim()).to.equal store2.name
        expect($("#stores [data-id='#{store2._id}'] .link", el).attr('href')).to.equal "store/#{store2.slug}"
    describe 'Without stores', ->
      before ->
        adminView = new AdminView el:el, stores: []
        adminView.render()
      it 'does not show the stores table', ->
        expect($("#stores", el).length).to.equal 0
