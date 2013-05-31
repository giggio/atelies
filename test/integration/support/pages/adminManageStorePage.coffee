Page = require './page'

module.exports = class AdminManageStorePage extends Page
  visit: (storeId, options, cb) ->
    if typeof storeId is 'string'
      super "admin#manageStore/#{storeId}", options, cb
    else
      [options, cb] = [storeId, options]
      super "admin#createStore", options, cb
  setFieldsAs: (store) =>
    @browser.fill "#manageStoreBlock #name", store.name
    @browser.fill "#manageStoreBlock #email", store.email
    @browser.fill "#manageStoreBlock #description", store.description
    @browser.fill "#manageStoreBlock #homePageDescription", store.homePageDescription
    @browser.fill "#manageStoreBlock #homePageImage", store.homePageImage
    @browser.fill "#manageStoreBlock #urlFacebook", store.urlFacebook
    @browser.fill "#manageStoreBlock #urlTwitter", store.urlTwitter
    @browser.fill "#manageStoreBlock #phoneNumber", store.phoneNumber
    @browser.fill "#manageStoreBlock #city", store.city
    @browser.select "#manageStoreBlock #state", store.state if store.state isnt ''
    @browser.fill "#manageStoreBlock #otherUrl", store.otherUrl
    @browser.fill "#manageStoreBlock #banner", store.banner
    @browser.fill "#manageStoreBlock #flyer", store.flyer
    @browser.evaluate "$('#manageStoreBlock #name,#email,#description,#phoneNumber,#city,#state,#otherUrl,#banner,#flyer').change()"
  clickUpdateStoreButton: (cb) => @browser.pressButton "#updateStore", cb
