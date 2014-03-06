Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class AdminManageStorePage extends Page
  visit: (storeId) ->
    if typeof storeId is 'string'
      super "admin/manageStore/#{storeId}"
    else
      cb = storeId
      super "admin/createStore"
  setFieldsAs: (store) ->
    Q.nfcall async.parallel, [
      (pcb) => @select("#manageStoreBlock #state", store.state).then pcb
      (pcb) => @hasElement("#manageStoreBlock #pagseguro").then (itHas) =>
        return pcb() unless itHas
        if store.pmtGateways.pagseguro?
          @check("#manageStoreBlock #pagseguro")
          .then => @type "#manageStoreBlock #pagseguroEmail", store.pmtGateways.pagseguro.email
          .then => @type "#manageStoreBlock #pagseguroToken", store.pmtGateways.pagseguro.token
          .then pcb
        else
          @uncheck("#manageStoreBlock #pagseguro").then pcb
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
  setPagseguroValuesAs: (val) ->
    @eval "$('#manageStoreBlock #pagseguroEmail').val('#{val.email}').change()"
    .then => @eval "$('#manageStoreBlock #pagseguroToken').val('#{val.token}').change()"
  clickUpdateStoreButton: @::pressButtonAndWait.partial "#updateStore"
  message: @::getText.partial '#message'
  hasMessage: @::hasElement.partial '#message'
  clickSetPagseguroButton: ->
    @waitForSelectorClickable "#setPagseguro"
    .then => @pressButton "#setPagseguro"
    .then => @waitForSelectorClickable "#confirmSetPagseguro"
  clickConfirmSetPagseguroButton: ->
    @waitForSelectorClickable "#confirmSetPagseguro"
    .then => @pressButtonAndWait "#confirmSetPagseguro"
    .then => waitMilliseconds 500
  clickUnsetPagseguroButton: ->
    @waitForSelectorClickable("#unsetPagseguro")
    .then => @pressButtonAndWait "#unsetPagseguro"
    .then => @waitForSelectorClickable "#confirmUnsetPagseguro"
  clickConfirmUnsetPagseguroButton: ->
    @waitForSelectorClickable "#confirmUnsetPagseguro"
    .then => @pressButtonAndWait("#confirmUnsetPagseguro")
    .then => waitMilliseconds 500
  pagseguroEmailErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroEmail"
  pagseguroTokenErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroToken"
  storeNameExistsModalVisible: @::isVisible.partial "#nameAlreadyExists"
  setName: (name) ->
    @type "#manageStoreBlock #name", name
    .then => @eval "$('#manageStoreBlock #name').change()"
  setPictureFiles: (bannerPath, flyerPath, homePageImagePath) =>
    @uploadFile '#banner', bannerPath
    .then => @uploadFile '#flyer', flyerPath
    .then => @uploadFile '#homePageImage', homePageImagePath
