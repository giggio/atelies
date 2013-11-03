Browser                 = require 'zombie'
AdminHomePage           = require './pages/adminHomePage'
LoginPage               = require './pages/loginPage'
RegisterPage            = require './pages/registerPage'
ChangePasswordPage      = require './pages/changePasswordPage'

#parser = require("html5")
#parser = require("htmlparser2")

exports.selectorLoaded = (w) ->
  w.document.querySelector @selectorSearched

exports.waitSelector = (selector, cb) ->
  @selectorSearched = selector
  @wait @selectorLoaded, cb

exports.pressButtonWait = (selector, cb) ->
  @waitSelector selector, => @pressButton selector, cb

exports.clickLinkWait = (selector, cb) ->
  @waitSelector selector, => @clickLink selector, cb

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
  browser.clickLinkWait = exports.clickLinkWait
  browser.adminHomePage = new AdminHomePage browser
  browser.loginPage = new LoginPage browser
  browser.changePasswordPage = new ChangePasswordPage browser
  browser.registerPage = new RegisterPage browser
  browser.showHtml = -> console.log browser.evaluate "$('html').html()"
  browser
