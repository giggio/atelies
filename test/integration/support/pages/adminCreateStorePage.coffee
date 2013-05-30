Page = require './page'

module.exports = class AdminCreateStorePage extends Page
  url: "admin#createStore"
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
  clickCreateStoreButton: (cb) => @browser.pressButton "#createStore", cb
