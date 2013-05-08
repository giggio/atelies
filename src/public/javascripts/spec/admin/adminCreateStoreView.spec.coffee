define [
  'jquery'
  'areas/admin/views/createStore'
], ($, CreateStoreView) ->
  el = $('<div></div>')
  describe 'CreateStoreView', ->
    describe 'Valid Store gets created', ->
      goToStoreManagePageSpy = storePassedIn = null
      store = generator.store.a()
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        global.adminStoresBootstrapModel = stores:[]
        createStoreView = new CreateStoreView el:el
        spyOn($, "ajax").andCallFake (opt) ->
          storePassedIn = JSON.parse opt.data
          opt.success store
        validSpy = spyOn($.fn, "valid").andReturn true
        goToStoreManagePageSpy = spyOn(createStoreView, '_goToStoreManagePage')
        createStoreView.render()
        createStoreView.$("#name").val store.name
        createStoreView.$("#phoneNumber").val store.phoneNumber
        createStoreView.$("#city").val store.city
        createStoreView.$("#state").val store.state
        createStoreView.$("#otherUrl").val store.otherUrl
        createStoreView.$("#banner").val store.banner
        $('#createStore', el).trigger 'click'
      it 'navigates to store manage page', ->
        expect(goToStoreManagePageSpy).toHaveBeenCalled()
        expect(goToStoreManagePageSpy.mostRecentCall.args[0].get('slug')).toBe store.slug
      it 'saves the correct data', ->
        expect(storePassedIn.name).toBe store.name
        expect(storePassedIn.phoneNumber).toBe store.phoneNumber
        expect(storePassedIn.city).toBe store.city
        expect(storePassedIn.state).toBe store.state
        expect(storePassedIn.otherUrl).toBe store.otherUrl
        expect(storePassedIn.banner).toBe store.banner
      it 'adds store to stores in the bootstrapped model', ->
        expect(global.adminStoresBootstrapModel.stores[0]).toEqual store

    describe 'invalid Store does not get created', ->
      ajaxSpy = goToStoreManagePageSpy = null
      store = generator.store.a()
      beforeEachCalled = false
      beforeEach ->
        return if beforeEachCalled
        beforeEachCalled = true
        createStoreView = new CreateStoreView el:el
        ajaxSpy = spyOn($, "ajax")
        validSpy = spyOn($.fn, "valid").andReturn false
        goToStoreManagePageSpy = spyOn(createStoreView, '_goToStoreManagePage')
        createStoreView.render()
        $('#createStore', el).trigger 'click'
      it 'does not navigate to store manage page', ->
        expect(goToStoreManagePageSpy).not.toHaveBeenCalled()
      it 'does not call ajax backend', ->
        expect(ajaxSpy).not.toHaveBeenCalled()
