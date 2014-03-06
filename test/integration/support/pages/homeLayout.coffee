Page = require './seleniumPage'

module.exports = class HomeLayout extends Page
  loginLinkExists: @::hasElement.partial "#loginPop"
  adminLinkExists: @::hasElement.partial "#admin"
  logoutLinkExists: @::hasElement.partial "#logout"
  userGreeting: -> @getText("#greeting").then (greeting) -> greeting.trim()
