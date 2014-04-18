define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  './views/siteAdmin'
  './views/approveStores'
  './models/storesForAuthorization'
  './models/storesForReport'
  './views/storesReport'
  '../shared/views/dialog'
],($, _, Backbone, viewsManager, SiteAdminView, ApproveStoresView, StoresForAuthorization, StoresForReport, StoresReportView, Dialog) ->
  class Router extends Backbone.Open.Router
    area: 'siteAdmin'
    logCategory: 'siteAdmin'
    constructor: ->
      viewsManager.$el = $ "#app-container > .siteAdmin"
      @_createRoutes
        '': @siteAdmin
        'stores': @stores
        'authorizeStores': @authorizeStores
        'authorizeStores/authorized': @authorizeStoresAuthorized
        'authorizeStores/unauthorized': @authorizeStoresUnauthorized
        'search/:searchTerm': @search
      _.bindAll @, _.functions(@)...
      super
    search: (searchTerm) -> window.location = "/search/#{searchTerm}"
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
        success: ->
          approveStoresView = new ApproveStoresView stores: stores
          viewsManager.show approveStoresView
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível buscar as lojas. Tente novamente mais tarde."
    stores: ->
      stores = new StoresForReport()
      stores.fetch
        reset:true
        success: ->
          view = new StoresReportView stores: stores
          viewsManager.show view
        error: (col, xhr, opt) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível buscar as lojas. Tente novamente mais tarde."
