define = require('amdefine')(module, requirejs) if (typeof define isnt 'function')
define [
  'jquery'
  'areas/admin/views/manageStore'
  'areas/admin/models/store'
  'areas/admin/models/stores'
  'backboneConfig'
  '../support/_specHelper'
], ($, ManageStoreView, Store, Stores) ->
  el = $('<div></div>')
  describe 'ManageStoreView', ->
    manageStoreView = null
    describe 'Valid Store gets created', ->
      ajaxSpy = exampleStore = store = goToStoreManagePageSpy = storePassedIn = null
      before ->
        exampleStore = generatorc.store.a()
        global.adminStoresBootstrapModel = stores:[]
        store = new Store()
        store._id = undefined
        stores = new Stores [store]
        user = verified: true
        manageStoreView = new ManageStoreView el:el, store:store, user: user
        ajaxSpy = sinon.stub $, "ajax", (opt) ->
          storePassedIn = JSON.parse opt.data
          opt.success exampleStore
        goToStoreManagePageSpy = sinon.spy manageStoreView, '_goToStoreManagePage'
        manageStoreView.render()
        manageStoreView.$("#name").val(exampleStore.name).change()
        manageStoreView.$("#phoneNumber").val(exampleStore.phoneNumber).change()
        manageStoreView.$("#city").val(exampleStore.city).change()
        manageStoreView.$("#state").val(exampleStore.state).change()
        manageStoreView.$("#zip").val(exampleStore.zip).change()
        manageStoreView.$("#otherUrl").val(exampleStore.otherUrl).change()
        manageStoreView.$("#pagseguro").prop('checked', true).change()
        manageStoreView.$("#pagseguroEmail").val(exampleStore.pagseguroEmail).change()
        manageStoreView.$("#pagseguroToken").val(exampleStore.pagseguroToken).change()
        $('#updateStore', el).trigger 'click'
      after ->
        ajaxSpy.restore()
        goToStoreManagePageSpy.restore()
        manageStoreView.close()
      it 'navigates to store manage page', ->
        expect(goToStoreManagePageSpy).to.have.beenCalled
        expect(goToStoreManagePageSpy.firstCall.args[0].get('slug')).to.equal exampleStore.slug
      it 'saves the correct data', ->
        expect(storePassedIn.name).to.equal exampleStore.name
        expect(storePassedIn.phoneNumber).to.equal exampleStore.phoneNumber
        expect(storePassedIn.city).to.equal exampleStore.city
        expect(storePassedIn.state).to.equal exampleStore.state
        expect(storePassedIn.zip).to.equal exampleStore.zip
        expect(storePassedIn.otherUrl).to.equal exampleStore.otherUrl
        expect(storePassedIn.pagseguro).to.be.true
        expect(storePassedIn.pagseguroEmail).to.equal exampleStore.pagseguroEmail
        expect(storePassedIn.pagseguroToken).to.equal exampleStore.pagseguroToken
      it 'adds store to stores in the bootstrapped model', ->
        expect(global.adminStoresBootstrapModel.stores[0]).to.be.like exampleStore

    describe 'User not verified redirects to inform that', ->
      it 'navigates to store manage page', ->
        user = verified: false
        manageStoreView = new ManageStoreView el:el, store:{}, user: user
        manageStoreView.render()
        window.location.should.equal "/account#userNotVerified"
        manageStoreView.close()

    describe 'invalid Store does not get created', ->
      ajaxSpy = goToStoreManagePageSpy = null
      before ->
        store = new Store()
        store._id = undefined
        stores = new Stores [store]
        user = verified: true
        manageStoreView = new ManageStoreView el:el, store:store, user:user
        ajaxSpy = sinon.spy $, "ajax"
        goToStoreManagePageSpy = sinon.spy manageStoreView, '_goToStoreManagePage'
        manageStoreView.render()
        manageStoreView.$("#otherUrl").val('abc').change()
        $('#updateStore', el).trigger 'click'
      after ->
        manageStoreView.close()
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

    describe 'Updating Store', ->
      ajaxSpy = newStore = stores = null
      describe 'Valid Store gets updated', ->
        goToStoreManagePageSpy = storePassedIn = null
        store = generatorc.store.a()
        newStore = generatorc.store.b()
        newStore.pagseguro = true
        newStore.pagseguroEmail = store.pagseguroEmail
        newStore.pagseguroToken = store.pagseguroToken
        newStore._id = store._id
        before ->
          global.adminStoresBootstrapModel = stores:[store]
          stores = new Stores [store]
          user = verified: true
          manageStoreView = new ManageStoreView el:el, store:stores.at(0), user:user
          ajaxSpy = sinon.stub $, "ajax", (opt) ->
            storePassedIn = JSON.parse opt.data
            opt.success newStore
          goToStoreManagePageSpy = sinon.spy manageStoreView, '_goToStoreManagePage'
          manageStoreView.render()
          manageStoreView.$("#name").val(newStore.name).change()
          manageStoreView.$("#phoneNumber").val(newStore.phoneNumber).change()
          manageStoreView.$("#city").val(newStore.city).change()
          manageStoreView.$("#state").val(newStore.state).change()
          manageStoreView.$("#zip").val(newStore.zip).change()
          manageStoreView.$("#otherUrl").val(newStore.otherUrl).change()
          $('#updateStore', el).trigger 'click'
        after ->
          manageStoreView.close()
          ajaxSpy.restore()
          goToStoreManagePageSpy.restore()
        it 'navigates to store manage page', ->
          expect(goToStoreManagePageSpy).to.have.beenCalled
          expect(goToStoreManagePageSpy.firstCall.args[0].get('slug')).to.equal newStore.slug
        it 'saves the correct data', ->
          expect(storePassedIn.name).to.equal newStore.name
          expect(storePassedIn.phoneNumber).to.equal newStore.phoneNumber
          expect(storePassedIn.city).to.equal newStore.city
          expect(storePassedIn.state).to.equal newStore.state
          expect(storePassedIn.zip).to.equal newStore.zip
          expect(storePassedIn.otherUrl).to.equal newStore.otherUrl
        it 'updates store to stores in the bootstrapped model', ->
          expect(global.adminStoresBootstrapModel.stores[0]).to.be.like newStore

      describe 'invalid Store does not get updated', ->
        ajaxSpy = goToStoreManagePageSpy = null
        before ->
          store = generatorc.store.a()
          stores = new Stores [store]
          user = verified: true
          manageStoreView = new ManageStoreView el:el, store:stores.at(0), user:user
          ajaxSpy = sinon.spy $, "ajax"
          goToStoreManagePageSpy = sinon.spy manageStoreView, '_goToStoreManagePage'
          manageStoreView.render()
          manageStoreView.$("#name").val('').change()
          manageStoreView.$("#city").val('').change()
          manageStoreView.$("#otherUrl").val('abc').change()
          $('#updateStore', el).trigger 'click'
        after ->
          manageStoreView.close()
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
