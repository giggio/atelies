Page = require './seleniumPage'

module.exports = class HomeLayout extends Page
  loginLinkExists: (cb) -> @hasElement "#loginPop", cb
  adminLinkExists: (cb) -> @hasElement "#admin", cb
  logoutLinkExists: (cb) -> @hasElement "#logout", cb
  userGreeting: (cb) -> @hasElement "#greeting", cb
