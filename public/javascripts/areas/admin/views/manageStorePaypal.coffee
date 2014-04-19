define [
  'jquery'
  'backboneConfig'
  'handlebars'
  '../models/storePaypal'
  'text!./templates/manageStorePaypal.html'
  'backboneValidation'
], ($, Backbone, Handlebars, StorePaypal, manageStorePaypalTemplate, Validation) ->
  class ManageStorePaypal extends Backbone.Open.View
    id: 'manageStorePaypalView'
    events:
      'click #confirmSetPaypal':'_confirmSetPaypal'
      'click #confirmUnsetPaypal':'_confirmUnsetPaypal'
    template: manageStorePaypalTemplate
    initialize: (opt) ->
      @model = new StorePaypal()
      context = Handlebars.compile @template
      @paypal = opt.paypal
      @storeId = opt.storeId
      @$el.html context paypal: @paypal, staticPath: @staticPath
      @bindings = @initializeBindings()
      Validation.bind @
    _confirmSetPaypal: -> @_setPaypal on; false
    _confirmUnsetPaypal: -> @_setPaypal off; false
    _setPaypal: (set) ->
      opt =
        url: "/api/admin/store/#{@storeId}/setPaypal"
        type: 'PUT'
        error: (xhr, text, error) =>
          @logXhrError 'admin', xhr
          if xhr.status isnt 409
            return @showDialogError "Não foi possível alterar o Paypal. Tente novamente mais tarde."
          $('#modalConfirmPaypal').one 'hidden.bs.modal', =>
            $('#modalCannotPaypal', @el).modal 'show'
            $("#confirmSetPaypal").prop "disabled", off
            $("#confirmUnsetPaypal").prop "disabled", off
          $('#modalConfirmPaypal', @el).modal 'hide'
        success: (data, text, xhr) =>
          @model.set 'paypal', set
          $('#modalConfirmPaypal').one 'hidden.bs.modal', => @trigger 'changed', paypal:set
          $('#modalConfirmPaypal', @el).modal 'hide'
      if set
        return unless @model.isValid true
        $("#confirmSetPaypal").prop "disabled", on
        $("#confirmUnsetPaypal").prop "disabled", on
        opt.url += "On"
        opt.data =
          clientId: $("#paypalClientId", @el).val()
          secret: $("#paypalSecret", @el).val()
      else
        opt.url += "Off"
      $.ajax opt
