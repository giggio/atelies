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
        expect($("#stores > tbody > tr", el).length).to.equal 2
        expect($("#stores > tbody > tr:first-child > td:first-child", el).text().trim()).to.equal store1.name
        expect($("#stores > tbody > tr:first-child > td:first-child > a", el).attr('href')).to.equal "#store/#{store1.slug}"
        expect($("#stores > tbody > tr:nth-child(2) > td:first-child", el).text().trim()).to.equal store2.name
        expect($("#stores > tbody > tr:nth-child(2) > td:first-child > a", el).attr('href')).to.equal "#store/#{store2.slug}"
    describe 'Without stores', ->
      before ->
        adminView = new AdminView el:el, stores: []
        adminView.render()
      it 'does not show the stores table', ->
        expect($("#stores", el).length).to.equal 0
