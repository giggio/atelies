define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/approveStore.html'
], ($, Backbone, Handlebars, approveStoreTemplate) ->
  class ApproveStoresView extends Backbone.Open.View
    events:
      'click .authorize':'_authorize'
      'click .unauthorize':'_unauthorize'
    template: approveStoreTemplate
    initialize: (opt) ->
      @store = opt.store
      context = Handlebars.compile @template
      storeAttr = @store.attributes
      storeAttr.canAuthorize = !storeAttr.isFlyerAuthorized? or !storeAttr.isFlyerAuthorized
      storeAttr.canUnauthorize = !storeAttr.isFlyerAuthorized? or storeAttr.isFlyerAuthorized
      @$el.html context storeAttr
    _authorize: ->
      @store.authorize
        error: (model, xhr, options) =>
          @logXhrError 'siteAdmin', xhr
          @showDialogError "Erro au autorizar. Tente novamente mais tarde."
    _unauthorize: ->
      @store.unauthorize
        error: (model, xhr, options) =>
          @logXhrError 'siteAdmin', xhr
          @showDialogError "Erro au reprovar. Tente novamente mais tarde."
