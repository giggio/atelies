Page          = require './seleniumPage'

module.exports = class SiteAdminHomePage extends Page
  url: 'siteAdmin'
  accessDeniedMessageIsVisible: @::hasElementAndIsVisible.partial "#accessDeniedMessage"
