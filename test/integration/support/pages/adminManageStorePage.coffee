Page          = require './seleniumPage'

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
    @type "#manageStoreBlock #homePageImage", store.homePageImage
    @type "#manageStoreBlock #urlFacebook", store.urlFacebook
    @type "#manageStoreBlock #urlTwitter", store.urlTwitter
    @type "#manageStoreBlock #phoneNumber", store.phoneNumber
    @type "#manageStoreBlock #city", store.city
    @type "#manageStoreBlock #zip", store.zip
    @type "#manageStoreBlock #otherUrl", store.otherUrl
    @type "#manageStoreBlock #banner", store.banner
    @type "#manageStoreBlock #flyer", store.flyer
    @checkOrUncheck "#manageStoreBlock #autoCalculateShipping", store.autoCalculateShipping, =>
      if store.state isnt ''
        @select "#manageStoreBlock #state", store.state, cb
      else
        cb()
  clickUpdateStoreButton: @::pressButton.partial "#updateStore"
  message: @::getText.partial '#message'
  hasMessage: @::hasElement.partial '#message'
