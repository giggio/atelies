webdriver       = require 'selenium-webdriver'
chromedriver    = require 'chromedriver'
connectUtils = require 'express/node_modules/connect/lib/utils'

webdriver.WebElement::type = (text) ->
  @clear().then => @sendKeys text

module.exports = class Page
  constructor: (url, page) ->
    [url, page] = [page, url] if url instanceof Page
    driver = page?.driver
    @url = url if url?
    if driver?
      @driver = driver
    else
      chromedriver.start()
      @driver = new webdriver.Builder()
        .usingServer('http://localhost:9515')
        .build()
      @driver.manage().timeouts().implicitlyWait 1000
  visit: (url, cb) ->
    url = @url unless url?
    promise = @driver.get "http://localhost:8000/#{url}"
    promise.then cb if cb?
  closeBrowser: (cb = (->)) ->
    stopDriver = ->
      chromedriver.stop()
      cb()
    @driver.quit().then stopDriver, cb
  errorMessageFor: (field, cb) -> @getText "##{field} ~ .tooltip .tooltip-inner", cb
  errorMessageForSelector: (selector, cb) -> @getText "#{selector} ~ .tooltip .tooltip-inner", cb
  errorMessagesIn: (selector, cb) -> @findElement(selector).findElements(webdriver.By.css('.tooltip-inner')).then (els) ->
    errorMsgs = {}
    flow = webdriver.promise.createFlow (f) =>
      for el in els
        do (el) ->
          f.execute =>
            el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id').then (id) ->
              el.getText().then (text) -> errorMsgs[id] = text
    flow.then (-> cb(errorMsgs)), cb
  findElement: (selector) -> @driver.findElement(webdriver.By.css(selector))
  findElements: (selector) -> @driver.findElements(webdriver.By.css(selector))
  clearCookies: (cb) -> @driver.manage().deleteAllCookies().then cb
  type: (selector, text) -> @findElement(selector).type text
  check: (selector, cb = (->)) ->
    el = @findElement selector
    el.isSelected().then (itIs) -> if itIs then process.nextTick cb else el.click().then cb
  uncheck: (selector, cb = (->)) ->
    el = @findElement selector
    el.isSelected().then (itIs) -> if itIs then el.click().then cb else process.nextTick cb
  getText: (selector, cb) -> @findElement(selector).getText().then cb
  getTexts: (selector, cb) ->
    texts = []
    flow = webdriver.promise.createFlow (f) =>
      @findElements(selector).then (els) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> texts.push text
        undefined
    flow.then (-> cb(texts)), cb
  getAttribute: (selector, attribute, cb) -> @findElement(selector).getAttribute(attribute).then cb
  getValue: @::getAttribute.partial(undefined, 'value', undefined)
  getSrc: @::getAttribute.partial(undefined, 'src', undefined)
  getIsChecked: (selector, cb) -> @findElement(selector).isSelected().then cb
  pressButton: (selector, cb = (->)) -> @findElement(selector).click().then cb
  clickLink: @::pressButton
  currentUrl: (cb) -> @driver.getCurrentUrl().then cb
  hasElement: (selector, cb) -> @driver.isElementPresent(webdriver.By.css(selector)).then cb
  parallel: (actions, cb) ->
    flow = webdriver.promise.createFlow (f) =>
      for action in actions
        do (action) -> f.execute action
      undefined
    flow.then cb, cb
  waitForUrl: (url, cb) -> @wait (=> @currentUrl().then((currentUrl) -> currentUrl is url)), 3000, cb
  wait: (fn, timeout, cb) ->
    @driver.wait fn, timeout
    process.nextTick cb
  visitBlank: (cb) -> Page::visit.call @, 'blank', cb
  loginFor: (_id, cb) ->
    @currentUrl (url) =>
      @visitBlank() unless url.substr(0,4) is 'http' #need the browser loaded to access cookies and have a session cookie id
      @driver.manage().getCookie('connect.sid').then (cookie) ->
        sessionId = cookie.value
        sessionStore = getExpressServer().sessionStore
        sessionId = connectUtils.parseSignedCookie decodeURIComponent(sessionId), getExpressServer().cookieSecret
        sessionStore.get sessionId, (err, session) ->
          session.auth = {} unless session.auth?
          auth = session.auth
          auth.userId = _id
          auth.loggedIn = true
          sessionStore.set sessionId, session, cb
  eval: (script, cb) -> @driver.executeScript(script).then cb
  clearLocalStorage: (cb) ->
    @visitBlank => @eval 'localStorage.clear()', cb
