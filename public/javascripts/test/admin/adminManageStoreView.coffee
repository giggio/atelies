define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/manageStore'
  'backboneConfig'
  '../support/_specHelper'
], ($, ManageStoreView) ->
  el = $('<div></div>')
  describe 'ManageStoreView', ->
    describe 'Valid Store gets created', ->
      goToStoreManagePageSpy = storePassedIn = null
      store = generatorc.store.a()
      before ->
        global.adminStoresBootstrapModel = stores:[]
        manageStoreView = new ManageStoreView el:el
        sinon.stub $, "ajax", (opt) ->
          storePassedIn = JSON.parse opt.data
          opt.success store
        goToStoreManagePageSpy = sinon.spy manageStoreView, '_goToStoreManagePage'
        manageStoreView.render()
        manageStoreView.$("#name").val(store.name).change()
        manageStoreView.$("#phoneNumber").val(store.phoneNumber).change()
        manageStoreView.$("#city").val(store.city).change()
        manageStoreView.$("#state").val(store.state).change()
        manageStoreView.$("#otherUrl").val(store.otherUrl).change()
        manageStoreView.$("#banner").val(store.banner).change()
        manageStoreView.$("#flyer").val(store.flyer).change()
        $('#updateStore', el).trigger 'click'
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
        expect(storePassedIn.flyer).to.equal store.flyer
      it 'adds store to stores in the bootstrapped model', ->
        expect(global.adminStoresBootstrapModel.stores[0]).to.be.like store

    describe 'invalid Store does not get created', ->
      ajaxSpy = goToStoreManagePageSpy = null
      store = generatorc.store.a()
      before ->
        manageStoreView = new ManageStoreView el:el
        ajaxSpy = sinon.spy $, "ajax"
        goToStoreManagePageSpy = sinon.spy manageStoreView, '_goToStoreManagePage'
        manageStoreView.render()
        manageStoreView.$("#otherUrl").val('abc').change()
        manageStoreView.$("#banner").val('def').change()
        manageStoreView.$("#flyer").val('ghi').change()
        $('#updateStore', el).trigger 'click'
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
        $("#flyer ~ .tooltip .tooltip-inner", el).text().should.equal "Informe um link válido para o flyer, começando com http ou https."
