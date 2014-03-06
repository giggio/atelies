Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class AdminHomePage extends Page
  url: 'admin'
  createStoreText: @::getValue.partial "#createStore"
  rows: @::findElements.partial '#stores .store'
  storesQuantity: -> @rows().then (rows) -> rows?.length or 0
  stores: ->
    @rows().then (rows) =>
      actions = []
      for row in rows
        do (row) =>
          actions.push (cb) => @getAttributeIn(row, 'a', 'href').then (href) -> cb null, url:href
      Q.nfcall async.parallel, actions
