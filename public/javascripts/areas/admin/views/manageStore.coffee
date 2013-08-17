define [
  'jquery'
  'backboneConfig'
  'handlebars'
  'text!./templates/manageStore.html'
  'text!./templates/validationErrors.html'
  './store'
  './manageStorePagseguro'
  'backboneValidation'
], ($, Backbone, Handlebars, manageStoreTemplate, validationErrorsTemplate, StoreView, ManageStorePagseguroView, Validation) ->
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
      @$el.html context new: isnew, autoCalculateShipping: @model.get('autoCalculateShipping'), pagseguro: @model.get('pagseguro'), staticPath: @staticPath
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
      validationErrorsEl = $('#validationErrors', @$el)
      valContext = Handlebars.compile validationErrorsTemplate
      @model.bind 'validated', (isValid, model, errors) =>
        if isValid
          validationErrorsEl.hide()
        else
          validationErrorsEl.html valContext errors:errors
          validationErrorsEl.show()
    _redirectIfUserNotSatisfied: ->
      unless @user.verified
        window.location = "/account#userNotVerified"
        return true
    _updateStore: =>
      return unless @model.isValid true
      $("#updateStore").prop "disabled", on
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
        error: (model, xhr, opt) =>
          @logXhrError 'admin', xhr
          $("#updateStore").prop "disabled", off
          return $('#nameAlreadyExists').modal() if xhr.status is 409
          if xhr.status is 422
            $('#sizeIsIncorrect .errorMsg', @$el).text JSON.parse(xhr.responseText).smallerThan
            return $('#sizeIsIncorrect').modal()
          @showDialogError "Não foi possível salvar a loja. Tente novamente mais tarde."
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
      $("#confirmSetAutoCalculateShipping").prop "disabled", on
      $("#confirmUnsetAutoCalculateShipping").prop "disabled", on
      url = "/admin/store/#{@model.get('_id')}/setAutoCalculateShipping"
      url += if set then "On" else "Off"
      $.ajax
        url: url
        type: 'PUT'
        error: (xhr, text, error) =>
          @logXhrError 'admin', xhr
          if xhr.status isnt 409
            return @showDialogError "Não foi possível alterar o cálculo automático de frete. Tente novamente mais tarde."
          $('#modalConfirmAutoCalculateShipping', @el).modal 'hide'
          $('#modalCannotAutoCalculateShipping', @el).modal 'show'
          $("#confirmSetAutoCalculateShipping").prop "disabled", off
          $("#confirmUnsetAutoCalculateShipping").prop "disabled", off
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
