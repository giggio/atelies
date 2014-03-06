webdriver       = require 'selenium-webdriver'
chromedriver    = require 'chromedriver'
connectUtils    = require 'express/node_modules/connect/lib/utils'
_               = require 'underscore'
async           = require 'async'
Q               = require 'q'

before ->
  chromedriver.start()
  capabilities =
    'browser': 'chrome',
    'chromeOptions':
      'prefs': {"profile.default_content_settings": {'images': 2}}
      'args': ["--host-rules=MAP * 127.0.0.1"]
  capabilities =
  Page.driver = new webdriver.Builder()
    .usingServer('http://localhost:9515')
    .withCapabilities(capabilities)
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
  _callbackOrPromise: (cb, promise) -> if cb? then promise.then(cb, cb) else promise
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
  errorMessagesIn: (selector, cb, i) ->
    d = Q.defer()
    i = 0 unless i?
    @_errorMessagesIn selector
    .then (errorMsgs) -> d.resolve errorMsgs
    .catch (err) => #retry if stale elements
      throw err if i > 1
      @errorMessagesIn(selector, cb, ++i).then (errorMsgs) -> d.resolve errorMsgs
    @_callbackOrPromise cb, d.promise

  _errorMessagesIn: (selector) ->
    errorMsgs = {}
    @findElement(selector)
    .then (el) -> el.findElements(webdriver.By.css('.tooltip-inner'))
    .then (els) =>
      actions =
        for el in els
          do (el) -> (cb2) =>
            success = (text) ->
              el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id').then (id) ->
                errorMsgs[id] = text
                cb2()
            el.getText().then success, -> cb2("error") #needs to have a fail callback to be able to deal with stale elements
      Q.nfcall async.parallel, actions
    .then -> errorMsgs
  findElement: (selector) ->
    return selector unless typeof selector is 'string'
    d = Q.defer()
    @driver.findElement(webdriver.By.css(selector))
    .then ((el) -> d.fulfill el), (err) -> d.reject err
    d.promise
  findElements: (selector, cb) -> @_callbackOrPromise cb, Q @driver.findElements(webdriver.By.css(selector))
  findElementIn: (selector, childSelector, cb) ->
    p = @findElement(selector)
    .then (el) -> el.findElement(webdriver.By.css(childSelector))
    @_callbackOrPromise cb, p
  findElementsIn: (selector, childrenSelector, cb) ->
    p = @findElement(selector)
    .then (el) -> el.findElements(webdriver.By.css(childrenSelector))
    @_callbackOrPromise cb, p
  clearCookies: (cb) -> @_callbackOrPromise cb, Q(@driver.manage().deleteAllCookies())
  type: (selector, text, cb) ->
    text = "" unless text?
    p = @findElement selector
    .then (el) ->
      Q el.clear()
      .then -> el.sendKeys text
    @_callbackOrPromise cb, p
  select: (selector, text, cb) ->
    if text is ''
      return setImmediate cb if cb?
      return Q.fcall ->
    p = @findElement(selector)
    .then (el) -> el.findElements(webdriver.By.tagName('option'))
    .then (els) ->
      elsWithText = []
      flow = webdriver.promise.createFlow (f) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> elsWithText.push {text: text, el: el}
        undefined
      Q(flow).then -> _.findWhere(elsWithText, text:text).el.click()
    @_callbackOrPromise cb, p
  checkOrUncheck: (selector, check, cb) ->
    if check
      @check selector, cb
    else
      @uncheck selector, cb
  check: (selector, cb) ->
    p = @findElement selector
    .then (el) ->
      Q el.isSelected()
      .then (itIs) -> Q(el.click()) unless itIs
    @_callbackOrPromise cb, p
  uncheck: (selector, cb) ->
    p = @findElement selector
    .then (el) ->
      Q el.isSelected()
      .then (itIs) -> Q(el.click()) if itIs
    @_callbackOrPromise cb, p
  getTextIn: (selector, childSelector, cb) ->
    @findElementIn selector, childSelector, (el) => @getText el, cb
  getAttributeInElements: (selector, attr, cb) ->
    Q @_callbackOrPromise cb, @findElements(selector)
    .then (els) =>
      getActions =
        for el in els
          do (el) =>
            (cb) => @getAttribute el, attr, (t) -> cb null, t
      Q.nfcall async.parallel, getActions
  getAttributeIn: (selector, childSelector, attr, cb) ->
    @findElementIn selector, childSelector, (el) =>
      @getAttribute el, attr, cb
  getTextIfExists: (selector) ->
    @hasElement selector
    .then (itHas) =>
      return null unless itHas
      @getText selector
  getText: (selector, cb) ->
    p = @findElement(selector).then (el) -> el.getText()
    @_callbackOrPromise cb, p
  getTexts: (selector, cb) ->
    texts = []
    flow = webdriver.promise.createFlow (f) =>
      @findElements(selector).then (els) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> texts.push text
        undefined
    flow.then (-> cb(texts)), cb
  getAttribute: (selector, attribute, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.getAttribute(attribute)
  getValue: @::getAttribute.partial(undefined, 'value', undefined)
  getSrc: @::getAttribute.partial(undefined, 'src', undefined)
  getSrcIn: @::getAttributeIn.partial(undefined, undefined, 'src', undefined)
  getIsClickable: (selector) ->
    @isVisible selector
    .then (itIs) =>
      return false unless itIs
      @getIsEnabled selector
  getIsChecked: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.isSelected()
  getIsEnabled: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.isEnabled()
  pressButtonLegacy: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.click()
  pressButtonJS: (id, cb) -> @_callbackOrPromise cb, @eval "document.getElementById('#{id}').click()"
  click: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.click()
  clickAndWait: (selector, cb) -> @_callbackOrPromise cb, @click(selector).then @waitForAjax
  pressButton: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.sendKeys(webdriver.Key.ENTER)
  pressButtonAndWait: (selector, cb) -> @_callbackOrPromise cb, @pressButton(selector).then @waitForAjax
  clickLink: @::pressButton
  currentUrl: (cb) -> @_callbackOrPromise cb, Q @driver.getCurrentUrl()
  hasElement: (selector, cb) -> @_callbackOrPromise cb, Q @driver.isElementPresent(webdriver.By.css(selector))
  hasElementAndIsVisible: (selector, cb) ->
    p = @hasElement selector
    .then (itHas) =>
      return false unless itHas
      @isVisible selector
    @_callbackOrPromise cb, p
  isVisible: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.isDisplayed()
  parallel: (actions) ->
    flow = webdriver.promise.createFlow (f) =>
      for action in actions
        do (action) -> f.execute action
      undefined
    Q flow
  waitForAjax: (cb) ->
    evalFn = => @eval 'return typeof($) !== \'undefined\' && $.active === 0;', (noActives) -> noActives
    @wait evalFn, 5000, cb
  waitForSelector: (selector) -> @wait (=> @hasElement(selector).then (itHas) -> itHas), 3000
  waitForSelectorClickable: (selector, i) ->
    tryWait = => @wait (=> @getIsClickable(selector).then (itIs) -> itIs), 3000
    d = Q.defer()
    i = 0 unless i?
    tryWait selector
    .then -> d.resolve()
    .catch (err) => #retry if stale elements
      throw err if i > 1
      @waitForSelectorClickable(selector, ++i).then -> d.resolve()
    d.promise
  waitForUrl: (url, cb) -> @wait (=> @currentUrl().then((currentUrl) -> currentUrl is url)), 3000, cb
  wait: (fn, timeout, cb) -> @_callbackOrPromise cb, Q(@driver.wait fn, timeout).then ->
  visitBlank: (cb) -> @_callbackOrPromise cb, Q Page::visit.call @, 'blank', false
  loginFor: (_id, cb) ->
    p = @currentUrl()
    .then (url) => @visitBlank() if url.substr(0,4) isnt 'http' #need the browser loaded to access cookies and have a session cookie id
    .then => @driver.manage().getCookie('connect.sid')
    .then (cookie) =>
      return cookie if cookie?
      @refresh().then => @driver.manage().getCookie('connect.sid')
    .then (cookie) =>
      server = getExpressServer()
      sessionStore = server.sessionStore
      cookieSecret = server.cookieSecret
      sessionId = connectUtils.parseSignedCookie decodeURIComponent(cookie.value), cookieSecret
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
  getHtml: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.getOuterHtml()
  getInnerHtml: (selector, cb) -> @_callbackOrPromise cb, @findElement(selector).then (el) -> el.getInnerHtml()
  getDialogMsg: ->
    @waitForSelectorClickable '.dialogMsg'
    .then => @getText '.dialogMsg'
  getDialogTitle: ->
    @waitForSelectorClickable '#dialogTitle'
    .then => @getText '#dialogTitle'
  getDialogTexts: ->
    @waitForSelectorClickable '#dialogTitle'
    .then => @getText '.dialogMsg'
    .then (dialogMsg) => @getText '#dialogTitle'
      .then (dialogTitle) => dialogMsg: dialogMsg, dialogTitle: dialogTitle
  closeDialog: @::pressButton.partial ".dialogClose"
  getParent: (el) ->
    d = Q.defer()
    el.findElement(webdriver.By.xpath('..'))
    .then ((el) -> d.fulfill el), (err) -> d.reject err
    d.promise
  uploadFile: (selector, path, cb) ->
    p = @findElement(selector)
    .then (el) => el.sendKeys path if path?
    @_callbackOrPromise cb, p
  waitForReady: (cb) ->
    evalFn = => @eval "return document.readyState === 'complete';", (itIs) -> itIs
    @wait evalFn, 5000, cb
  captureAttribute: captureAttribute
