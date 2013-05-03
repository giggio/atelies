Page = require './pages/page'
module.exports = class AdminCreateStorePage extends Page
  constructor: (@browser) ->
  visit: (options, cb) => super "admin#createStore", options, cb
  setFieldsAs: (store) =>
    @browser.fill "#name", store.name
    @browser.fill "#phoneNumber", store.phoneNumber
    @browser.fill "#city", store.city
    @browser.select "#state", store.state if store.state isnt ''
    @browser.fill "#otherUrl", store.otherUrl
    @browser.fill "#banner", store.banner
  clickCreateStoreButton: (cb) => @browser.pressButton "#createStore", cb
