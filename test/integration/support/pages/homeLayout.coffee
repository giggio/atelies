Page = require './page'

module.exports = class HomeLayout extends Page
  loginLinkExists: => @browser.query("#loginPop")?
  adminLinkExists: => @browser.query("#admin")?
  logoutLinkExists: => @browser.query("#logout")?
  userGreeting: => @browser.text("#greeting")
