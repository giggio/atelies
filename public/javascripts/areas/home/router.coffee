define [
  'backbone'
  './routes'
],
(Backbone, routes) ->
  class Router extends Backbone.Open.Router
    _routes: routes
    routes:
      '': routes.home
      'home': routes.home
      'searchStores': routes.searchStores
      'closeSearchStore': routes.closeSearchStore
      'searchStores/:searchTerm': routes.searchStore
      'searchProducts/:searchTerm': routes.searchProducts
