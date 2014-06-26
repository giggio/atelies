Page          = require './seleniumPage'

module.exports = class SiteAdminAuthorizeStoresPage extends Page
  url: 'siteAdmin/authorizeStores'
  accessDeniedMessageIsVisible: @::hasElementAndIsVisible.partial "#accessDeniedMessage"
  storesToAuthorize: @::findElements.partial "#stores .store.toAuthorize"
  storesToUnauthorize: @::findElements.partial "#stores .store.toUnauthorize"
  clickAuthorize: (store) -> @pressButtonAndWait "#store#{store._id} .authorize"
  clickUnauthorize: (store) -> @pressButtonAndWait "#store#{store._id} .unauthorize"
