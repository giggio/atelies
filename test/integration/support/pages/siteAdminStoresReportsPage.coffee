Page          = require './seleniumPage'
async         = require 'async'
Q             = require 'q'

module.exports = class SiteAdminAuthorizeStoresPage extends Page
  url: 'siteAdmin/stores'
  storesQuantity: -> @findElementsIn('#storesReport', '.store').then captureAttribute "length"
  stores: ->
    @findElementsIn '#storesReport', '.store'
    .then (storeElements) =>
      for storeEl in storeElements
        name: @getTextIn storeEl, '.name'
        email: @getTextIn storeEl, '.email'
        url: @getHrefIn storeEl, '.name a'
        phoneNumber: @getTextIn storeEl, '.phoneNumber'
        sellerName: @getTextIn storeEl, '.ownerName'
        sellerEmail: @getTextIn storeEl, '.ownerEmail'
        numberOfOrders: @getTextIn(storeEl, '.numberOfOrders').then parseInt
        numberOfProducts: @getTextIn(storeEl, '.numberOfProducts').then parseInt
        categories: @getTextIn storeEl, '.categories'
    .then (storePromiseObjs) =>
      storesPromises = (@resolveObj storePromiseObj for storePromiseObj in storePromiseObjs)
      Q.all storesPromises
      .then (stores) ->
        stores
  storeIn: (pos) -> @stores().then (s) -> s[0]
