zombie                  = new require 'zombie'
StoreCartPage           = require './storeCartPage'
StoreProductPage        = require './storeProductPage'
AdminCreateStorePage    = require './adminCreateStorePage'

exports.selectorLoaded = (w) ->
  console.log "waiting #{@selectorSearched}"
  w.document.querySelector @selectorSearched

exports.waitSelector = (selector, cb) ->
  @selectorSearched = selector
  @wait @selectorLoaded, cb

exports.pressButtonWait = (selector, cb) ->
  @waitSelector selector, => @pressButton selector, cb

exports.newBrowser = (browser) ->
  storage = browser?.saveStorage()
  browser = new zombie.Browser()
  browser.loadStorage storage if storage?
  browser.selectorSearched = exports.selectorSearched
  browser.waitSelector = exports.waitSelector
  browser.pressButtonWait = exports.pressButtonWait
  browser.storeCartPage = new StoreCartPage browser
  browser.storeProductPage = new StoreProductPage browser
  browser.adminCreateStorePage = new AdminCreateStorePage browser
  browser
