webdriver       = require 'selenium-webdriver'
chromedriver    = require 'chromedriver'
connectUtils    = require 'express/node_modules/connect/lib/utils'
_               = require 'underscore'
async           = require 'async'

before ->
  chromedriver.start()
  Page.driver = new webdriver.Builder()
    .usingServer('http://localhost:9515')
    #.withCapabilities({'browserName': 'chrome', 'prefs': {"profile.default_content_settings": {'images': 2}}})
    .build()
  Page.driver.manage().timeouts().implicitlyWait 2000
after (done) ->
  Page.driver.quit().then ->
    chromedriver.stop()
    done()

module.exports = class Page
  constructor: (url, page) ->
    [url, page] = [page, url] if url instanceof Page
    @url = url if url?
    @driver = Page.driver
  visit: (url, refresh, cb) ->
    [refresh, cb] = [cb, refresh] if typeof refresh is 'function'
    [cb, url] = [url, cb] if typeof url is 'function'
    refresh = false unless refresh?
    url = @url unless url?
    url = "http://localhost:8000/#{url}" unless url.substr(0,4).toLowerCase() is 'http'
    @driver.get('chrome://version/').then => #chrome version is the fastest page to load. Ideally we'd use about:blank, but that fails sometimes, as selenium does not recognize it finished loading and never calls back
      @driver.get(url).then =>
        if refresh
          @refresh cb
        else
          cb() if cb?
  closeBrowser: (cb) -> cb() if cb?
  errorMessageFor: (field, cb) -> @errorMessageForSelector "##{field}", cb
  errorMessageForSelector: (selector, cb) ->
    @findElements "#{selector} ~ .tooltip .tooltip-inner", (els) =>
      if els?.length > 0
        el = els[0]
      else
        return cb null
      @getText el, cb
  errorMessagesIn: (selector, cb) -> @findElement(selector).findElements(webdriver.By.css('.tooltip-inner')).then (els) ->
    errorMsgs = {}
    actions =
      for el in els
        do (el) -> (cb2) =>
          el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id').then (id) ->
            el.getText().then (text) ->
              errorMsgs[id] = text
              cb2()
    async.parallel actions, -> cb(errorMsgs)
  findElement: (selector) -> if typeof selector is 'string' then @driver.findElement(webdriver.By.css(selector)) else selector
  findElements: (selector, cb) ->
    find = @driver.findElements(webdriver.By.css(selector))
    if cb?
      find.then cb
    else
      find
  findElementIn: (selector, childSelector, cb) ->
    el = if typeof selector is 'string' then @findElement(selector) else selector
    el.findElement(webdriver.By.css(childSelector)).then cb, cb
  findElementsIn: (selector, childrenSelector, cb) ->
    el = if typeof selector is 'string' then @findElement(selector) else selector
    el.findElements(webdriver.By.css(childrenSelector)).then cb
  clearCookies: (cb) -> @driver.manage().deleteAllCookies().then cb
  type: (selector, text, cb) ->
    @findElement(selector).then (el) =>
      el.clear().then =>
        el.sendKeys text if text?
        cb() if cb?
  select: (selector, text, cb) ->
    return setImmediate cb if text is ''
    @findElement(selector).findElements(webdriver.By.tagName('option')).then (els) ->
      elsWithText = []
      flow = webdriver.promise.createFlow (f) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> elsWithText.push {text: text, el: el}
        undefined
      flow.then ->
        _.findWhere(elsWithText, text:text).el.click().then cb
      , cb
  checkOrUncheck: (selector, check, cb) ->
    if check
      @check selector, cb
    else
      @uncheck selector, cb
  check: (selector, cb = (->)) ->
    el = @findElement selector
    el.isSelected().then (itIs) -> if itIs then process.nextTick cb else el.click().then cb
  uncheck: (selector, cb = (->)) ->
    el = @findElement selector
    el.isSelected().then (itIs) -> if itIs then el.click().then cb else process.nextTick cb
  getTextIn: (selector, childSelector, cb) ->
    @findElementIn selector, childSelector, (el) => @getText el, cb
  getAttributeIn: (selector, childSelector, attr, cb) ->
    @findElementIn selector, childSelector, (el) =>
      @getAttribute el, attr, cb
  getTextIfExists: (selector, cb) ->
    @hasElement selector, (itHas) =>
      return cb null unless itHas
      @getText selector, cb
  getText: (selector, cb) ->
    el = if typeof selector is 'string' then @findElement(selector) else selector
    el.getText().then cb
  getTexts: (selector, cb) ->
    texts = []
    flow = webdriver.promise.createFlow (f) =>
      @findElements(selector).then (els) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> texts.push text
        undefined
    flow.then (-> cb(texts)), cb
  getAttribute: (selector, attribute, cb) ->
    el = if typeof selector is 'string' then @findElement(selector) else selector
    el.getAttribute(attribute).then cb
  getValue: @::getAttribute.partial(undefined, 'value', undefined)
  getSrc: @::getAttribute.partial(undefined, 'src', undefined)
  getIsClickable: (selector, cb) ->
    @isVisible selector, =>
      @getIsEnabled selector, cb
  getIsChecked: (selector, cb) -> @findElement(selector).isSelected().then cb
  getIsEnabled: (selector, cb) -> @findElement(selector).isEnabled().then cb
  pressButton: (selector, cb = (->)) -> @findElement(selector).click().then cb
  pressButtonAndWait: (selector, cb) -> @pressButton selector, => @waitForAjax cb
  clickLink: @::pressButton
  currentUrl: (cb) -> @driver.getCurrentUrl().then cb
  hasElement: (selector, cb) -> @driver.isElementPresent(webdriver.By.css(selector)).then cb
  isVisible: (selector, cb) -> @eval "return $('#{selector}').is(':visible')", cb #or could use isDiplayed
  parallel: (actions, cb) ->
    flow = webdriver.promise.createFlow (f) =>
      for action in actions
        do (action) -> f.execute action
      undefined
    flow.then cb, cb
  waitForAjax: (cb) -> @wait (=> @eval('return $.active;', (active) -> active is 0)), 5000, cb
  waitForSelector: (selector, cb) -> @wait (=> @hasElement(selector, (itHas) -> itHas)), 3000, cb
  waitForSelectorClickable: (selector, cb) -> @wait (=> @getIsClickable(selector, (itIs) -> itIs)), 3000, cb
  waitForUrl: (url, cb) -> @wait (=> @currentUrl().then((currentUrl) -> currentUrl is url)), 3000, cb
  wait: (fn, timeout, cb) ->
    @driver.wait fn, timeout
    process.nextTick cb
  visitBlank: (cb) -> Page::visit.call @, 'blank', false, cb
  loginFor: (_id, cb) ->
    @currentUrl (url) =>
      doLogin = =>
        @driver.manage().getCookie('connect.sid').then (cookie) =>
          continueLogin = (cookie) =>
            sessionId = cookie.value
            sessionStore = getExpressServer().sessionStore
            sessionId = connectUtils.parseSignedCookie decodeURIComponent(sessionId), getExpressServer().cookieSecret
            sessionStore.get sessionId, (err, session) ->
              session.auth = {} unless session.auth?
              auth = session.auth
              auth.userId = _id
              auth.loggedIn = true
              sessionStore.set sessionId, session, cb
          if cookie?
            continueLogin cookie
          else
            @refresh =>
              @driver.manage().getCookie('connect.sid').then (cookie) =>
                continueLogin cookie
      if url.substr(0,4) isnt 'http' #need the browser loaded to access cookies and have a session cookie id
        @visitBlank doLogin
      else
        doLogin()
  eval: (script, cb) -> @driver.executeScript(script).then cb
  clearLocalStorage: (cb) ->
    @currentUrl (url) =>
      clear = => @eval 'localStorage.clear()', cb
      if url.substr(0,4) isnt 'http' #need the browser loaded to access localstorage
        @visitBlank clear
      else
        clear()
  refresh: (cb = (->)) -> @driver.navigate().refresh().then cb, cb
  getHtml: (selector, cb) -> @findElement(selector).getOuterHtml().then cb
  getInnerHtml: (selector, cb) -> @findElement(selector).getInnerHtml().then cb
  getDialogMsg: (cb) ->
    @waitForSelectorClickable '#dialogMsg', =>
      @getText '#dialogMsg', cb
  getDialogTitle: (cb) ->
    @waitForSelectorClickable '#dialogTitle', =>
      @getText '#dialogTitle', cb
  getDialogTexts: (cb) ->
    @waitForSelectorClickable '#dialogTitle', =>
      @getText '.dialogMsg', (dialogMsg) =>
        @getText '#dialogTitle', (dialogTitle) =>
          cb dialogMsg: dialogMsg, dialogTitle: dialogTitle
