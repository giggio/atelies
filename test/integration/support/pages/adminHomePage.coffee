Page          = require './seleniumPage'
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
          actions.push @getAttributeIn(row, 'a', 'href').then (href) -> url:href
      Q.all actions
