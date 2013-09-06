define [
  'backboneConfig'
  'areas/siteAdmin/routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    logCategory: 'siteAdmin'
    _routes: routes
    routes:
      '': routes.siteAdmin
      'authorizeStores': routes.authorizeStores
      'authorizeStores/authorized': routes.authorizeStoresAuthorized
      'authorizeStores/unauthorized': routes.authorizeStoresUnauthorized
