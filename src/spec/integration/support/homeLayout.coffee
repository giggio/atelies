module.exports = class HomeLayout
  constructor: (@browser) ->
  loginLinkExists: => @browser.query("#loginPop")?
  adminLinkExists: => @browser.query("#admin")?
  logoutLinkExists: => @browser.query("#logout")?
  userGreeting: => @browser.text("#greeting")
