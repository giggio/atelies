define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'text!./templates/manageStore.html'
  'text!./templates/validationErrors.html'
  './store'
  './manageStorePagseguro'
  './manageStorePaypal'
  'backboneValidation'
], ($, _, Backbone, Handlebars, manageStoreTemplate, validationErrorsTemplate, StoreView, ManageStorePagseguroView, ManageStorePaypalView, Validation) ->
  class ManageStoreView extends Backbone.Open.View
    events:
      'click #updateStore':'_updateStore'
      'change #pagseguro':'_pagseguroChanged'
      'change #paypal':'_paypalChanged'
    template: manageStoreTemplate
    initialize: (opt) ->
      @model = opt.store
      @user = opt.user
      return if @_redirectIfUserNotSatisfied()
      context = Handlebars.compile @template
      isnew = @model.id? is false
      @$el.html context new: isnew, paypal: @model.get('paypal'), pagseguro: @model.get('pagseguro'), staticPath: @staticPath
      @bindings = @initializeBindings
        '#paypal':'checked:paypal'
        '#pagseguro':'checked:pagseguro'
        "#showFlyer": "attr:{src:flyer}"
        "#showBanner": "attr:{src:banner}"
      if isnew
        @model.on 'change:pagseguro', => @_pagseguroChanged()
        @model.on 'change:paypal', => @_paypalChanged()
      else
        delete @bindings['#pagseguro']
        delete @bindings['#pagseguroEmail']
        delete @bindings['#pagseguroToken']
        delete @model.validation.pagseguroEmail
        delete @model.validation.pagseguroToken
        manageStorePagseguroView = new ManageStorePagseguroView pagseguro: @model.get('pagseguro'), storeId: @model.get('_id')
        $('#pagseguroOptions', @$el).html manageStorePagseguroView.el
        manageStorePagseguroView.on 'changed', (opt) =>
          @model.set 'pagseguro', opt.pagseguro
          @_storeCreated @model
        manageStorePagseguroView.render()
        delete @bindings['#paypal']
        delete @bindings['#paypalClientId']
        delete @bindings['#paypalSecret']
        delete @model.validation.paypalClientId
        delete @model.validation.paypalSecret
        manageStorePaypalView = new ManageStorePaypalView paypal: @model.get('paypal'), storeId: @model.get('_id')
        $('#paypalOptions', @$el).html manageStorePaypalView.el
        manageStorePaypalView.on 'changed', (opt) =>
          @model.set 'paypal', opt.paypal
          @_storeCreated @model
        manageStorePaypalView.render()
      Validation.bind @
      validationErrorsEl = $('#validationErrors', @$el)
      valContext = Handlebars.compile validationErrorsTemplate
      _.defer =>
        @model.bind 'validated', (isValid, model, errors) ->
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
      if (typeof bannerVal isnt 'undefined' and bannerVal isnt '') or (typeof flyerVal isnt 'undefined' and flyerVal isnt '')
        @model.hasFiles = true
        @model.form = $('#manageStore')
      else
        @model.hasFiles = true
        @model.hasFiles = false
      @model.save @model.attributes,
        success: (model) => @_storeCreated model
        error: (model, xhr, opt) =>
          $("#updateStore").prop "disabled", off
          return $('#nameAlreadyExists').modal() if xhr.status is 409
          if xhr.status is 422
            $('#sizeIsIncorrect .errorMsg', @$el).text JSON.parse(xhr.responseText).smallerThan
            return $('#sizeIsIncorrect').modal()
          @logXhrError 'admin', xhr
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
    _goToStoreManagePage: (store, update) ->
      StoreView.justCreated = !update
      StoreView.justUpdated = update
      Backbone.history.navigate "store/#{store.get('slug')}", trigger: true
    _pagseguroChanged: ->
      pagseguro = @model.get 'pagseguro'
      val = @model.validation
      for v in [ val.pagseguroEmail, val.pagseguroToken ]
        v.reverse()
        requiredIndex = if pagseguro then 0 else 1
        v[requiredIndex].required = pagseguro
      Validation.bind @
      @model.validate()
    _paypalChanged: ->
      paypal = @model.get 'paypal'
      val = @model.validation
      v.required = paypal for v in [ val.paypalClientId, val.paypalSecret ]
      Validation.bind @
      @model.validate()
