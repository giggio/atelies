define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/createStore'
  'backboneConfig'
  '../support/_specHelper'
], ($, CreateStoreView) ->
  el = $('<div></div>')
  describe 'CreateStoreView', ->
    describe 'Valid Store gets created', ->
      goToStoreManagePageSpy = storePassedIn = null
      store = generator.store.a()
      before ->
        global.adminStoresBootstrapModel = stores:[]
        createStoreView = new CreateStoreView el:el
        sinon.stub $, "ajax", (opt) ->
          storePassedIn = JSON.parse opt.data
          opt.success store
        goToStoreManagePageSpy = sinon.spy createStoreView, '_goToStoreManagePage'
        createStoreView.render()
        createStoreView.$("#name").val(store.name).change()
        createStoreView.$("#phoneNumber").val(store.phoneNumber).change()
        createStoreView.$("#city").val(store.city).change()
        createStoreView.$("#state").val(store.state).change()
        createStoreView.$("#otherUrl").val(store.otherUrl).change()
        createStoreView.$("#banner").val(store.banner).change()
        $('#createStore', el).trigger 'click'
      after ->
        $.ajax.restore()
        goToStoreManagePageSpy.restore()
      it 'navigates to store manage page', ->
        expect(goToStoreManagePageSpy).to.have.beenCalled
        expect(goToStoreManagePageSpy.firstCall.args[0].get('slug')).to.equal store.slug
      it 'saves the correct data', ->
        expect(storePassedIn.name).to.equal store.name
        expect(storePassedIn.phoneNumber).to.equal store.phoneNumber
        expect(storePassedIn.city).to.equal store.city
        expect(storePassedIn.state).to.equal store.state
        expect(storePassedIn.otherUrl).to.equal store.otherUrl
        expect(storePassedIn.banner).to.equal store.banner
      it 'adds store to stores in the bootstrapped model', ->
        expect(global.adminStoresBootstrapModel.stores[0]).to.be.like store

    describe 'invalid Store does not get created', ->
      ajaxSpy = goToStoreManagePageSpy = null
      store = generator.store.a()
      before ->
        createStoreView = new CreateStoreView el:el
        ajaxSpy = sinon.spy $, "ajax"
        goToStoreManagePageSpy = sinon.spy createStoreView, '_goToStoreManagePage'
        createStoreView.render()
        createStoreView.$("#otherUrl").val('abc').change()
        createStoreView.$("#banner").val('def').change()
        $('#createStore', el).trigger 'click'
      after ->
        ajaxSpy.restore()
        goToStoreManagePageSpy.restore()
      it 'does not navigate to store manage page', ->
        expect(goToStoreManagePageSpy).not.to.have.beenCalled
      it 'does not call ajax backend', ->
        expect(ajaxSpy).not.to.have.beenCalled
      it 'shows validation message', ->
        $("#name ~ .tooltip .tooltip-inner", el).text().should.equal 'Informe o nome da loja.'
        $("#city ~ .tooltip .tooltip-inner", el).text().should.equal 'Informe a cidade.'
        $("#otherUrl ~ .tooltip .tooltip-inner", el).text().should.equal 'Informe um link válido para o outro site, começando com http ou https.'
        $("#banner ~ .tooltip .tooltip-inner", el).text().should.equal "Informe um link válido para o banner, começando com http ou https."
