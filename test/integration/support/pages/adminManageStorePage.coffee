Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class AdminManageStorePage extends Page
  visit: (storeId) ->
    if typeof storeId is 'string'
      super "admin/manageStore/#{storeId}"
    else
      super "admin/createStore"
  setFieldsAs: (store) ->
    Q.all [
      @select("#manageStoreBlock #state", store.state)
      @hasElement("#manageStoreBlock #pagseguro").then (itHas) =>
        return unless itHas
        if store.pmtGateways.pagseguro?
          @check "#manageStoreBlock #pagseguro"
          .then => @type "#manageStoreBlock #pagseguroEmail", store.pmtGateways.pagseguro.email
          .then => @type "#manageStoreBlock #pagseguroToken", store.pmtGateways.pagseguro.token
        else
          @uncheck("#manageStoreBlock #pagseguro")
      @hasElement("#manageStoreBlock #paypal").then (itHas) =>
        return unless itHas
        if store.pmtGateways.paypal?
          @check("#manageStoreBlock #paypal")
          .then => @type "#manageStoreBlock #paypalClientId", store.pmtGateways.paypal.clientId
          .then => @type "#manageStoreBlock #paypalSecret", store.pmtGateways.paypal.secret
        else
          @uncheck "#manageStoreBlock #paypal"
    ]
    .then => @type "#manageStoreBlock #name", store.name
    .then => @type "#manageStoreBlock #email", store.email
    .then => @type "#manageStoreBlock #description", store.description
    .then => @type "#manageStoreBlock #urlFacebook", store.urlFacebook
    .then => @type "#manageStoreBlock #urlTwitter", store.urlTwitter
    .then => @type "#manageStoreBlock #phoneNumber", store.phoneNumber
    .then => @type "#manageStoreBlock #city", store.city
    .then => @type "#manageStoreBlock #zip", store.zip
    .then => @type "#manageStoreBlock #otherUrl", store.otherUrl
  clickUpdateStoreButton: @::pressButtonAndWait.partial "#updateStore"
  message: @::getText.partial '#message'
  hasMessage: @::hasElement.partial '#message'
  setPagseguroValuesAs: (val) ->
    @eval "$('#manageStoreBlock #pagseguroEmail').val('#{val.email}').change()"
    .then => @eval "$('#manageStoreBlock #pagseguroToken').val('#{val.token}').change()"
  clickSetPagseguroButton: ->
    @waitForSelectorClickable "#setPagseguro"
    .then => @pressButton "#setPagseguro"
    .then => @waitForSelectorClickable "#confirmSetPagseguro"
  clickConfirmSetPagseguroButton: ->
    @waitForSelectorClickable "#confirmSetPagseguro"
    .then => @pressButtonAndWait "#confirmSetPagseguro"
    .then -> waitMilliseconds 500
  clickUnsetPagseguroButton: ->
    @waitForSelectorClickable("#unsetPagseguro")
    .then => @pressButtonAndWait "#unsetPagseguro"
    .then => @waitForSelectorClickable "#confirmUnsetPagseguro"
  clickConfirmUnsetPagseguroButton: ->
    @waitForSelectorClickable "#confirmUnsetPagseguro"
    .then => @pressButtonAndWait("#confirmUnsetPagseguro")
    .then -> waitMilliseconds 500
  pagseguroEmailErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroEmail"
  pagseguroTokenErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPagseguro #pagseguroToken"
  setPaypalValuesAs: (val) ->
    @eval "$('#manageStoreBlock #paypalClientId').val('#{val.clientId}').change()"
    .then => @eval "$('#manageStoreBlock #paypalSecret').val('#{val.secret}').change()"
  clickSetPaypalButton: ->
    @waitForSelectorClickable "#setPaypal"
    .then => @pressButton "#setPaypal"
    .then => @waitForSelectorClickable "#confirmSetPaypal"
  clickConfirmSetPaypalButton: ->
    @waitForSelectorClickable "#confirmSetPaypal"
    .then => @pressButtonAndWait "#confirmSetPaypal"
    .then -> waitMilliseconds 500
  clickUnsetPaypalButton: ->
    @waitForSelectorClickable("#unsetPaypal")
    .then => @pressButtonAndWait "#unsetPaypal"
    .then => @waitForSelectorClickable "#confirmUnsetPaypal"
  clickConfirmUnsetPaypalButton: ->
    @waitForSelectorClickable "#confirmUnsetPaypal"
    .then => @pressButtonAndWait("#confirmUnsetPaypal")
    .then -> waitMilliseconds 500
  paypalClientIdErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPaypal #paypalClientId"
  paypalSecretErrorMsg: @::errorMessageForSelector.partial "#modalConfirmPaypal #paypalSecret"
  storeNameExistsModalVisible: @::isVisible.partial "#nameAlreadyExists"
  setName: (name) ->
    @type "#manageStoreBlock #name", name
    .then => @eval "$('#manageStoreBlock #name').change()"
  setPictureFiles: (bannerPath, flyerPath) =>
    @uploadFile '#banner', bannerPath
    .then => @uploadFile '#flyer', flyerPath
