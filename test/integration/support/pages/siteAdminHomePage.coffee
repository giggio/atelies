Page          = require './seleniumPage'
async         = require 'async'

module.exports = class SiteAdminHomePage extends Page
  url: 'siteAdmin'
  accessDeniedMessageIsVisible: @::hasElementAndIsVisible.partial "#accessDeniedMessage"
