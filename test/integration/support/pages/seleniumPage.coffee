webdriver       = require 'selenium-webdriver'
chromedriver    = require 'chromedriver'
connectUtils    = require 'express/node_modules/connect/lib/utils'
_               = require 'underscore'
async           = require 'async'
Q               = require 'q'

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
    _.bindAll @, _.functions(@)...
  _callbackOrPromise: (cb, promise) -> if cb? then promise.then cb else promise
  visit: (url, refresh, cb) ->
    [refresh, cb] = [cb, refresh] if typeof refresh is 'function'
    [cb, url] = [url, cb] if typeof url is 'function'
    refresh = false unless refresh?
    url = @url unless url?
    url = "http://localhost:8000/#{url}" unless url.substr(0,4).toLowerCase() is 'http'
    Q(@driver.get('chrome://version/')) #chrome version is the fastest page to load. Ideally we'd use about:blank, but that fails sometimes, as selenium does not recognize it finished loading and never calls back
    .then => @driver.get(url)
    .then =>
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
  errorMessagesIn: (selector, cb) -> @findElement(selector).findElements(webdriver.By.css('.tooltip-inner')).then (els) =>
    errorMsgs = {}
    actions =
      for el in els
        do (el) -> (cb2) =>
          success = (text) ->
            el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id').then (id) ->
              errorMsgs[id] = text
              cb2()
          el.getText().then success, -> cb2("error") #needs to have a fail callback to be able to deal with stale elements
    async.parallel actions, (err) =>
      if err? #retry if stale elements
        return setImmediate => @errorMessagesIn(selector, cb)
      cb(errorMsgs)
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
  clearCookies: (cb) -> @_callbackOrPromise cb, Q(@driver.manage().deleteAllCookies())
  type: (selector, text, cb) ->
    text = "" unless text?
    el = @findElement selector
    p = Q(el.clear().then -> el.sendKeys text)
    @_callbackOrPromise cb, p
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
  check: (selector, cb) ->
    el = @findElement selector
    p = Q(el.isSelected())
    .then (itIs) -> Q(el.click()) unless itIs
    @_callbackOrPromise cb, p
  uncheck: (selector, cb) ->
    el = @findElement selector
    p = Q(el.isSelected())
    .then (itIs) -> Q(el.click()) if itIs
    @_callbackOrPromise cb, p
  getTextIn: (selector, childSelector, cb) ->
    @findElementIn selector, childSelector, (el) => @getText el, cb
  getAttributeInElements: (selector, attr, cb) ->
    @findElements selector, (els) =>
      getActions =
        for el in els
          do (el) =>
            (cb) => @getAttribute el, attr, (t) -> cb null, t
      async.parallel getActions, (err, vals) -> cb vals
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
  getSrcIn: @::getAttributeIn.partial(undefined, undefined, 'src', undefined)
  getIsClickable: (selector, cb) ->
    @isVisible selector, (itIs) =>
      return cb false unless itIs
      @getIsEnabled selector, cb
  getIsChecked: (selector, cb) -> @findElement(selector).isSelected().then cb
  getIsEnabled: (selector, cb) -> @findElement(selector).isEnabled().then cb
  pressButtonLegacy: (selector, cb = (->)) -> @findElement(selector).click().then cb
  pressButtonJS: (id, cb) -> @_callbackOrPromise cb, @eval "document.getElementById('#{id}').click()"
  click: (selector, cb) -> @_callbackOrPromise cb, Q @findElement(selector).click()
  pressButton: (selector, cb) -> @_callbackOrPromise cb, Q @findElement(selector).sendKeys(webdriver.Key.ENTER)
  pressButtonAndWait: (selector, cb) -> @_callbackOrPromise cb, @pressButton(selector).then @waitForAjax
  clickLink: @::pressButton
  currentUrl: (cb) -> @_callbackOrPromise cb, Q @driver.getCurrentUrl()
  hasElement: (selector, cb) -> @driver.isElementPresent(webdriver.By.css(selector)).then cb
  hasElementAndIsVisible: (selector, cb) ->
    @hasElement selector, (itHas) =>
      return cb false unless itHas
      @isVisible selector, cb
  isVisible: (selector, cb) -> @findElement(selector).isDisplayed().then cb
  parallel: (actions, cb) ->
    flow = webdriver.promise.createFlow (f) =>
      for action in actions
        do (action) -> f.execute action
      undefined
    flow.then cb, cb
  waitForAjax: (cb) ->
    evalFn = => @eval 'return typeof($) !== \'undefined\' && $.active === 0;', (noActives) -> noActives
    @wait evalFn, 5000, cb
  waitForSelector: (selector, cb) -> @wait (=> @hasElement(selector, (itHas) -> itHas)), 3000, cb
  waitForSelectorClickable: (selector, cb) -> @wait (=> @getIsClickable(selector, (itIs) -> itIs)), 3000, cb
  waitForUrl: (url, cb) -> @wait (=> @currentUrl().then((currentUrl) -> currentUrl is url)), 3000, cb
  wait: (fn, timeout, cb) -> @_callbackOrPromise cb, Q(@driver.wait fn, timeout).then ->
  visitBlank: (cb) -> @_callbackOrPromise cb, Q Page::visit.call @, 'blank', false
  loginFor: (_id, cb) ->
    p = @currentUrl()
    .then (url) => @visitBlank() if url.substr(0,4) isnt 'http' #need the browser loaded to access cookies and have a session cookie id
    .then => @driver.manage().getCookie('connect.sid')
    .then (cookie) =>
      if cookie?
        cookie
      else
        @refresh().then => @driver.manage().getCookie('connect.sid')
    .then (cookie) =>
      sessionId = cookie.value
      sessionStore = getExpressServer().sessionStore
      sessionId = connectUtils.parseSignedCookie decodeURIComponent(sessionId), getExpressServer().cookieSecret
      Q.ninvoke sessionStore, 'get', sessionId
      .then (session) ->
        session.auth = {} unless session.auth?
        auth = session.auth
        auth.userId = _id
        auth.loggedIn = true
        Q.ninvoke sessionStore, 'set', sessionId, session
    @_callbackOrPromise cb, p
  eval: (script, cb) ->
    p = Q(@driver.executeScript(script))
    @_callbackOrPromise cb, p
  clearLocalStorage: (cb) ->
    p = @currentUrl()
    .then (url) => @visitBlank() if url.substr(0,4) isnt 'http' #need the browser loaded to access localstorage
    .then => @eval 'localStorage.clear()'
    @_callbackOrPromise cb, p
  refresh: (cb) ->
    p = Q(@driver.navigate().refresh())
    @_callbackOrPromise cb, p
  reload: @::refresh
  getHtml: (selector, cb) -> @findElement(selector).getOuterHtml().then cb
  getInnerHtml: (selector, cb) -> @findElement(selector).getInnerHtml().then cb
  getDialogMsg: (cb) ->
    @waitForSelectorClickable '.dialogMsg', =>
      @getText '.dialogMsg', cb
  getDialogTitle: (cb) ->
    @waitForSelectorClickable '#dialogTitle', =>
      @getText '#dialogTitle', cb
  getDialogTexts: (cb) ->
    @waitForSelectorClickable '#dialogTitle', =>
      @getText '.dialogMsg', (dialogMsg) =>
        @getText '#dialogTitle', (dialogTitle) =>
          cb dialogMsg: dialogMsg, dialogTitle: dialogTitle
  getParent: (el) -> el.findElement(webdriver.By.xpath('..'))
  uploadFile: (selector, path, cb) ->
    @findElement(selector).then (el) =>
      el.sendKeys path if path?
      cb() if cb?
  waitForReady: (cb) ->
    evalFn = => @eval "return document.readyState === 'complete';", (itIs) -> itIs
    @wait evalFn, 5000, cb
