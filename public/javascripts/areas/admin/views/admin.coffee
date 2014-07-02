define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/admin.html'
], ($, Backbone, Handlebars, adminTemplate) ->
  class AdminView extends Backbone.Open.View
    @setDialog: (dialog) -> @_dialog = dialog
    @_getDialog: ->
      [dialog, @_dialog] = [@_dialog, null]
      dialog
    events:
      'click #createStore': -> Backbone.history.navigate 'createStore', true
    template: adminTemplate
    initialize: (opt) =>
      @stores = opt.stores
      @dialog = opt.dialog or AdminView._getDialog()
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      storeGroups = @_groupStores @stores
      @$el.html context storeGroups:storeGroups, hasStores:@stores.length isnt 0
      if @dialog? then @showDialog @dialog.message, @dialog.title
      super
    _groupStores: (stores) ->
      _.reduce stores, (groups, store) ->
        if groups.length is 0 or _.last(groups).stores.length is 4 then groups.push stores:[]
        _.last(groups).stores.push store
        groups
      , []
