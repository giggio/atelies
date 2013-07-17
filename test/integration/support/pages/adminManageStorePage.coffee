Page          = require './seleniumPage'
async         = require 'async'

module.exports = class AdminManageStorePage extends Page
  visit: (storeId, cb) ->
    if typeof storeId is 'string'
      super "admin#manageStore/#{storeId}", cb
    else
      cb = storeId
      super "admin#createStore", cb
  setFieldsAs: (store, cb) =>
    @type "#manageStoreBlock #name", store.name
    @type "#manageStoreBlock #email", store.email
    @type "#manageStoreBlock #description", store.description
    @type "#manageStoreBlock #homePageDescription", store.homePageDescription
    @type "#manageStoreBlock #urlFacebook", store.urlFacebook
    @type "#manageStoreBlock #urlTwitter", store.urlTwitter
    @type "#manageStoreBlock #phoneNumber", store.phoneNumber
    @type "#manageStoreBlock #city", store.city
    @type "#manageStoreBlock #zip", store.zip
    @type "#manageStoreBlock #otherUrl", store.otherUrl
    store.autoCalculateShipping = true unless store.autoCalculateShipping?
    store.pmtGateways = {} unless store.pmtGateways?
    async.parallel [
      (pcb) => @hasElement "#manageStoreBlock #autoCalculateShipping", (itHas) =>
        if itHas
          @checkOrUncheck "#manageStoreBlock #autoCalculateShipping", store.autoCalculateShipping, pcb
        else
          pcb()
      (pcb) => @hasElement "#manageStoreBlock #pagseguro", (itHas) =>
        if itHas
          if store.pmtGateways.pagseguro?
            @check "#manageStoreBlock #pagseguro", =>
              @type "#manageStoreBlock #pagseguroEmail", store.pmtGateways.pagseguro.email
              @type "#manageStoreBlock #pagseguroToken", store.pmtGateways.pagseguro.token
              pcb()
          else
            @uncheck "#manageStoreBlock #pagseguro", pcb
        else
          pcb()
      (pcb) => @select "#manageStoreBlock #state", store.state, pcb
    ], cb
  setPagseguroValuesAs: (val, cb) ->
    @eval "$('#manageStoreBlock #pagseguroEmail').val('#{val.email}').change()", =>
      @eval "$('#manageStoreBlock #pagseguroToken').val('#{val.token}').change()", cb
  clickUpdateStoreButton: @::pressButton.partial "#updateStore"
  message: @::getText.partial '#message'
  hasMessage: @::hasElement.partial '#message'
  autoCalculateShippingErrorMsg: @::getText.partial "#modalCannotAutoCalculateShipping .modal-body"
  clickSetAutoCalculateShippingButton: @::pressButton.partial "#setAutoCalculateShipping"
  clickConfirmSetAutoCalculateShippingButton: (cb) => @eval "$('#confirmSetAutoCalculateShipping').click()", cb
  clickUnsetAutoCalculateShippingButton: @::pressButton.partial "#unsetAutoCalculateShipping"
  clickConfirmUnsetAutoCalculateShippingButton: (cb) => @eval "$('#confirmUnsetAutoCalculateShipping').click()", cb
  clickSetPagseguroButton: @::pressButton.partial "#setPagseguro"
  clickConfirmSetPagseguroButton: (cb) => @eval "$('#confirmSetPagseguro').click()", cb
  clickUnsetPagseguroButton: @::pressButton.partial "#unsetPagseguro"
  clickConfirmUnsetPagseguroButton: (cb) => @eval "$('#confirmUnsetPagseguro').click()", cb
  pagseguroEmailErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroEmail"
  pagseguroTokenErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroToken"
