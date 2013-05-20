Browser                 = require 'zombie'
HomePage                = require './pages/homePage'
StoreHomePage           = require './pages/storeHomePage'
StoreCartPage           = require './pages/storeCartPage'
StoreProductPage        = require './pages/storeProductPage'
AdminCreateStorePage    = require './pages/adminCreateStorePage'
AdminHomePage           = require './pages/adminHomePage'
LoginPage               = require './pages/loginPage'
RegisterPage            = require './pages/registerPage'
AdminManageStorePage    = require './pages/adminManageStorePage'
AdminManageProductPage  = require './pages/adminManageProductPage'

#parser = require("html5")
#parser = require("htmlparser2")

exports.selectorLoaded = (w) ->
  w.document.querySelector @selectorSearched

exports.waitSelector = (selector, cb) ->
  @selectorSearched = selector
  @wait @selectorLoaded, cb

exports.pressButtonWait = (selector, cb) ->
  @waitSelector selector, => @pressButton selector, cb

exports.newBrowser = (browser) ->
  if browser?
    storage = browser.saveStorage()
    browser.destroy()
  browser = new Browser maxWait: 20, site: "http://localhost:8000/"#, htmlParser: parser
  browser.loadStorage storage if storage?
  browser.selectorLoaded = exports.selectorLoaded
  browser.selectorSearched = exports.selectorSearched
  browser.waitSelector = exports.waitSelector
  browser.pressButtonWait = exports.pressButtonWait
  browser.homePage = new HomePage browser
  browser.storeHomePage = new StoreHomePage browser
  browser.storeCartPage = new StoreCartPage browser
  browser.storeProductPage = new StoreProductPage browser
  browser.adminCreateStorePage = new AdminCreateStorePage browser
  browser.adminHomePage = new AdminHomePage browser
  browser.loginPage = new LoginPage browser
  browser.registerPage = new RegisterPage browser
  browser.adminManageStorePage = new AdminManageStorePage browser
  browser.adminManageProductPage = new AdminManageProductPage browser
  browser.showHtml = -> console.log browser.evaluate "$('html').html()"
  browser
