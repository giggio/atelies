Page          = require './seleniumPage'
async         = require 'async'

module.exports = class SiteAdminAuthorizeStoresPage extends Page
  url: 'siteAdmin#authorizeStores'
  accessDeniedMessageIsVisible: @::hasElementAndIsVisible.partial "#accessDeniedMessage"
  storesToAuthorize: @::findElements.partial "#stores .store.toAuthorize"
  storesToUnauthorize: @::findElements.partial "#stores .store.toUnauthorize"
  clickAuthorize: (store, cb) ->
    @pressButtonAndWait "#store#{store._id} .authorize", cb
  clickUnauthorize: (store, cb) ->
    @pressButtonAndWait "#store#{store._id} .unauthorize", cb
