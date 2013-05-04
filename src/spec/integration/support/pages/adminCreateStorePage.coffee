Page = require './page'

module.exports = class AdminCreateStorePage extends Page
  url: "admin#createStore"
  setFieldsAs: (store) =>
    @browser.fill "#name", store.name
    @browser.fill "#phoneNumber", store.phoneNumber
    @browser.fill "#city", store.city
    @browser.select "#state", store.state if store.state isnt ''
    @browser.fill "#otherUrl", store.otherUrl
    @browser.fill "#banner", store.banner
  clickCreateStoreButton: (cb) => @browser.pressButton "#createStore", cb
