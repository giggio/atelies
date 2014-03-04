Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class AdminManageStorePage extends Page
  visit: (storeId, cb) ->
    if typeof storeId is 'string'
      super "admin/manageStore/#{storeId}", cb
    else
      cb = storeId
      super "admin/createStore", cb
  setFieldsAs: (store) =>
    Q.nfcall async.parallel, [
      (pcb) => @select "#manageStoreBlock #state", store.state, pcb
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
    ]
    .then => @type "#manageStoreBlock #name", store.name
    .then => @type "#manageStoreBlock #email", store.email
    .then => @type "#manageStoreBlock #description", store.description
    .then => @type "#manageStoreBlock #homePageDescription", store.homePageDescription
    .then => @type "#manageStoreBlock #urlFacebook", store.urlFacebook
    .then => @type "#manageStoreBlock #urlTwitter", store.urlTwitter
    .then => @type "#manageStoreBlock #phoneNumber", store.phoneNumber
    .then => @type "#manageStoreBlock #city", store.city
    .then => @type "#manageStoreBlock #zip", store.zip
    .then => @type "#manageStoreBlock #otherUrl", store.otherUrl
  setPagseguroValuesAs: (val, cb) ->
    @eval "$('#manageStoreBlock #pagseguroEmail').val('#{val.email}').change()", =>
      @eval "$('#manageStoreBlock #pagseguroToken').val('#{val.token}').change()", cb
  clickUpdateStoreButton: @::pressButton.partial "#updateStore"
  message: @::getText.partial '#message'
  hasMessage: @::hasElement.partial '#message'
  clickSetPagseguroButton: (cb) ->
    @pressButton "#setPagseguro", =>
      @waitForSelectorClickable "#confirmSetPagseguro", cb
  clickConfirmSetPagseguroButton: (cb) ->
    @pressButtonAndWait "#confirmSetPagseguro", => waitMilliseconds 500, cb
  clickUnsetPagseguroButton: (cb) ->
    @pressButton "#unsetPagseguro", =>
      @waitForSelectorClickable "#confirmUnsetPagseguro", cb
  clickConfirmUnsetPagseguroButton: (cb) ->
    @pressButtonAndWait "#confirmUnsetPagseguro", => waitMilliseconds 500, cb
  pagseguroEmailErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroEmail"
  pagseguroTokenErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroToken"
  storeNameExistsModalVisible: @::isVisible.partial "#nameAlreadyExists"
  setName: (name) ->
    @type "#manageStoreBlock #name", name
    .then => @eval "$('#manageStoreBlock #name').change()"
  setPictureFiles: (bannerPath, flyerPath, homePageImagePath, cb) =>
    @uploadFile '#banner', bannerPath, =>
      @uploadFile '#flyer', flyerPath, =>
        @uploadFile '#homePageImage', homePageImagePath, cb
