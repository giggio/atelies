Page          = require './seleniumPage'
async         = require 'async'

module.exports = class AdminHomePage extends Page
  url: 'admin'
  createStoreText: @::getValue.partial "#createStore"
  rows: @::findElements.partial '#stores .store'
  storesQuantity: (cb) ->
    @rows (rows) =>
      cb if rows? then rows.length else 0
  stores: (cb) ->
    @rows (rows) =>
      actions = []
      for row in rows
        do (row) =>
          actions.push (cb) => @getAttributeIn row, 'a', 'href', (href) -> cb null, url:href
      async.parallel actions, (err, stores) -> cb stores
