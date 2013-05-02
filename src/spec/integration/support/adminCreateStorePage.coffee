module.exports = class AdminCreateStorePage
  constructor: (@browser) ->
  visit: (cb) => @browser.visit "http://localhost:8000/admin#createStore", cb
  setFieldsAs: (store, cb) =>
    @browser.fill "#name", store.name
    @browser.fill "#phoneNumber", store.phoneNumber
    @browser.fill "#city", store.city
    @browser.fill "#state", store.state
    @browser.fill "#otherUrl", store.otherUrl
    @browser.fill "#banner", store.banner
  clickCreateStoreButton: (cb) => @browser.pressButtonWait "#createStore", cb
