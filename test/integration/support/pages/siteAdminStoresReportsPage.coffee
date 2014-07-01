Page          = require './seleniumPage'
Q             = require 'q'
$             = require 'jquery'

module.exports = class SiteAdminAuthorizeStoresPage extends Page
  url: 'siteAdmin/stores'
  storesQuantity: -> @findElementsIn('#storesReport', '.store').then captureAttribute "length"
  stores: ->
    @findElementsIn '#storesReport', '.store'
    .then (storeElements) =>
      storePromiseObjs = for storeEl in storeElements
        name: @getTextIn storeEl, '.name'
        email: @getAttributeIn(storeEl, '.name', 'data-content').then (content) ->
          $(content)[0].href.replace "mailto:",""
        url: @getHrefIn storeEl, '.name a'
        phoneNumber: @getAttributeIn(storeEl, '.name', 'data-content').then (content) ->
          $(content)[2].href.replace "tel:",""
        sellerName: @getTextIn storeEl, '.ownerName'
        sellerEmail: @getHrefIn(storeEl, '.ownerName a').then (href) -> href.replace "mailto:", ""
        numberOfOrders: @getTextIn(storeEl, '.numberOfOrders').then parseInt
        numberOfProducts: @getTextIn(storeEl, '.numberOfProducts').then parseInt
        categories: @getTextIn storeEl, '.categories'
      Q.all (@resolveObj storePromiseObj for storePromiseObj in storePromiseObjs)
  storeIn: (pos) -> @stores().then (s) -> s[pos]
