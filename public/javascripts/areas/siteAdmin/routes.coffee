define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  './views/siteAdmin'
  './views/approveStores'
  './models/storesForAuthorization'
  '../shared/views/dialog'
],($, _, Backbone, viewsManager, SiteAdminView, ApproveStoresView, StoresForAuthorization, Dialog) ->
  class Routes extends Backbone.Open.Routes
    area: 'siteAdmin'
    constructor: ->
      viewsManager.$el = $ "#app-container > .siteAdmin"
    siteAdmin: ->
      homeView = new SiteAdminView()
      viewsManager.show homeView
    authorizeStores: -> @_authorizeStoresWithStatus()
    authorizeStoresAuthorized: -> @_authorizeStoresWithStatus true
    authorizeStoresUnauthorized: -> @_authorizeStoresWithStatus false
    _authorizeStoresWithStatus: (status) ->
      stores = new StoresForAuthorization status: status
      stores.fetch
        reset:true
        success: =>
          approveStoresView = new ApproveStoresView stores: stores
          viewsManager.show approveStoresView
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível buscar as lojas. Tente novamente mais tarde."

  _.bindAll new Routes()
