define [
  'jquery'
  'backbone'
  'handlebars'
  'text!./templates/admin.html'
], ($, Backbone, Handlebars, adminTemplate) ->
  class AdminView extends Backbone.View
    events:
      'click #createStore': -> Backbone.history.navigate 'createStore', true
    template: adminTemplate
    initialize: (opt) =>
      @stores = opt.stores
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      storeGroups = @_groupStores @stores
      @$el.html context storeGroups:storeGroups, hasStores:@stores.length isnt 0
    _groupStores: (stores) ->
      _.reduce stores, (groups, store) ->
        if groups.length is 0 or _.last(groups).stores.length is 4 then groups.push stores:[]
        _.last(groups).stores.push store
        groups
      , []
