define [
  'jquery'
  'underscore'
  'backboneConfig'
  '../../viewsManager'
  './views/home'
  './models/search'
  '../shared/views/dialog'
],($, _, Backbone, viewsManager, HomeView, Search, Dialog) ->
  class Router extends Backbone.Open.Router
    logCategory: 'home'
    area: 'home'
    constructor: ->
      @_createRoutes
        '': @home
        'home': @home
        'search/:searchTerm': @search
      viewsManager.$el = $ "#app-container > .home"
      _.bindAll @, _.functions(@)...
      super
    home: ->
      @homeView = new HomeView products: homeProductsBootstrapModel, stores: homeStoresBootstrapModel
      viewsManager.show @homeView
    search: (searchTerm) ->
      @home() unless @homeView?
      $('#productSearchTerm').val searchTerm
      if searchTerm.length < 3
        $('#doSearchProduct').popover 'show'
        return setTimeout (-> $('#doSearchProduct').popover 'hide'), 5000
      $('#doSearchProduct').popover 'hide'
      search = new Search searchTerm:searchTerm
      search.fetch
        success: (data, textStatus, xhr) => @homeView.showSearchResults searchTerm, data
        error: (xhr, textStatus, errorThrown) =>
          @logXhrError xhr
          Dialog.showError viewsManager.$el, "Não foi possível realizar a busca. Tente novamente mais tarde."
