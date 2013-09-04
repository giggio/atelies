define [
  'jquery'
  'underscore'
  '../../viewsManager'
  './views/siteAdmin'
],($, _, viewsManager, SiteAdminView) ->
  class Routes extends Backbone.Open.Routes
    area: 'siteAdmin'
    constructor: ->
      viewsManager.$el = $ "#app-container > .siteAdmin"
    siteAdmin: ->
      homeView = new SiteAdminView()
      viewsManager.show homeView

  _.bindAll new Routes()
