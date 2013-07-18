define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/manageStore.html'
  './store'
  './manageStorePagseguro'
  'backboneValidation'
], ($, Backbone, Handlebars, manageStoreTemplate, StoreView, ManageStorePagseguroView, Validation) ->
  class ManageStoreView extends Backbone.Open.View
    events:
      'click #updateStore':'_updateStore'
      'click #confirmSetAutoCalculateShipping':'_confirmSetAutoCalculateShipping'
      'click #confirmUnsetAutoCalculateShipping':'_confirmUnsetAutoCalculateShipping'
      'change #pagseguro':'_pagseguroChanged'
    template: manageStoreTemplate
    initialize: (opt) ->
      @model = opt.store
      @user = opt.user
      return if @_redirectIfUserNotSatisfied()
      context = Handlebars.compile @template
      isnew = @model.id? is false
      @$el.html context new: isnew, autoCalculateShipping: @model.get('autoCalculateShipping'), pagseguro: @model.get('pagseguro')
      @bindings = @initializeBindings
        '#autoCalculateShipping':'checked:autoCalculateShipping'
        '#pagseguro':'checked:pagseguro'
        "#showFlyer": "attr:{src:flyer}"
        "#showHomePageImage": "attr:{src:homePageImage}"
        "#showBanner": "attr:{src:banner}"
      if isnew
        @model.on 'change:pagseguro', => @_pagseguroChanged()
      else
        delete @bindings['#autoCalculateShipping']
        delete @bindings['#pagseguro']
        delete @bindings['#pagseguroEmail']
        delete @bindings['#pagseguroToken']
        delete @model.validation.pagseguroEmail
        delete @model.validation.pagseguroToken
        manageStorePagseguroView = new ManageStorePagseguroView pagseguro: @model.get('pagseguro'), storeId: @model.get('_id')
        $('#pagseguroOptions', @$el).html manageStorePagseguroView.el
        manageStorePagseguroView.render()
        manageStorePagseguroView.on 'changed', (opt) =>
          @model.set 'pagseguro', opt.pagseguro
          @_storeCreated @model
      Validation.bind @
      #@model.bind 'validated:invalid', (model, errors) -> console.log errors
    _redirectIfUserNotSatisfied: ->
      unless @user.verified
        window.location = "/account#userNotVerified"
        return true
    _updateStore: =>
      return unless @model.isValid true
      bannerVal = $('#banner').val()
      flyerVal = $('#flyer').val()
      homePageImageVal = $('#homePageImage').val()
      if (typeof bannerVal isnt 'undefined' and bannerVal isnt '') or (typeof flyerVal isnt 'undefined' and flyerVal isnt '') or (typeof homePageImageVal isnt 'undefined' and homePageImageVal isnt '')
        @model.hasFiles = true
        @model.form = $('#manageStore')
      else
        @model.hasFiles = true
        @model.hasFiles = false
      @model.save @model.attributes,
        success: (model) => @_storeCreated model
        error: (model, xhr, opt) ->
          return $('#nameAlreadyExists').modal() if xhr.status is 409
          throw message:'error when saving'
    _storeCreated: (store) =>
      update = false
      existingStore = _.findWhere adminStoresBootstrapModel.stores, _id: store.get('_id')
      if existingStore?
        update = true
        index = adminStoresBootstrapModel.stores.indexOf existingStore
        adminStoresBootstrapModel.stores.splice index, 1
      adminStoresBootstrapModel.stores.push store.attributes
      @_goToStoreManagePage store, update
    _goToStoreManagePage: (store, update) =>
      StoreView.justCreated = !update
      StoreView.justUpdated = update
      Backbone.history.navigate "store/#{store.get('slug')}", trigger: true
    _confirmSetAutoCalculateShipping: -> @_setAutoCalculateShipping on
    _confirmUnsetAutoCalculateShipping: -> @_setAutoCalculateShipping off
    _setAutoCalculateShipping: (set) ->
      url = "/admin/store/#{@model.get('_id')}/setAutoCalculateShipping"
      url += if set then "On" else "Off"
      $.ajax
        url: url
        type: 'PUT'
        error: (xhr, text, error) ->
          return console.log error, xhr if xhr.status isnt 409
          $('#modalConfirmAutoCalculateShipping', @el).modal 'hide'
          $('#modalCannotAutoCalculateShipping', @el).modal 'show'
        success: (data, text, xhr) =>
          @model.set 'autoCalculateShipping', set
          $('#modalConfirmAutoCalculateShipping', @el).modal 'hide'
          @_storeCreated @model
    _pagseguroChanged: ->
      pagseguro = @model.get 'pagseguro'
      val = @model.validation
      for v in [ val.pagseguroEmail, val.pagseguroToken ]
        v.reverse()
        requiredIndex = if pagseguro then 0 else 1
        v[requiredIndex].required = pagseguro
      Validation.bind @
      @model.validate()
