webdriver       = require 'selenium-webdriver'
connectUtils    = require 'express/node_modules/connect/lib/utils'
_               = require 'underscore'
async           = require 'async'
Q               = require 'q'

useChrome = on

before ->
  if useChrome
    chromedriver = require 'chromedriver'
    chrome = require "selenium-webdriver/chrome"
    chromeServiceBuilder = new chrome.ServiceBuilder chromedriver.path
    chromeServiceBuilder.args_.push "--whitelisted-ips"
    capabilities = webdriver.Capabilities.chrome()
    capabilities.set 'chromeOptions',
      'prefs': {"profile.default_content_settings": {'images': 2}}
      'args': ["--host-rules=MAP * 127.0.0.1", '--test-type']
    service = chromeServiceBuilder.build()
    Page.driver = chrome.createDriver capabilities, service
  else
    phantomjs = require 'phantomjs'
    capabilities = webdriver.Capabilities.phantomjs()
    capabilities.set 'phantomjs.binary.path', phantomjs.path
    Page.driver = new webdriver.Builder()
      .withCapabilities(capabilities)
      .build()
  Page.driver.manage().timeouts().implicitlyWait 2000

after -> Page.driver.quit()

module.exports = class Page
  constructor: (url, page) ->
    [url, page] = [page, url] if url instanceof Page
    @url = url if url?
    @driver = Page.driver
    _.bindAll @, _.functions(@)...
  visit: (url, refresh = false) ->
    url = @url unless url?
    url = "http://localhost:8000/#{url}" unless url.substr(0,4).toLowerCase() is 'http'
    Q(@driver.get('data:,')) #chrome version is the fastest page to load. Ideally we'd use about:blank, but that fails sometimes, as selenium does not recognize it finished loading and never calls back
    .then => @driver.get(url)
    .then => @refresh() if refresh
  errorMessageFor: (field) -> @errorMessageForSelector "##{field}"
  errorMessageForSelector: (selector) ->
    @findElements "#{selector} ~ .tooltip .tooltip-inner"
    .then (els) =>
      if els?.length > 0
        el = els[0]
      else
        return
      @getText el
  errorMessagesIn: (selector, i) ->
    d = Q.defer()
    i = 0 unless i?
    @_errorMessagesIn selector
    .then (errorMsgs) -> d.resolve errorMsgs
    .catch (err) => #retry if stale elements
      throw err if i > 1
      @errorMessagesIn(selector, ++i).then (errorMsgs) -> d.resolve errorMsgs
    d.promise
  _errorMessagesIn: (selector) ->
    errorMsgs = {}
    @findElement(selector)
    .then (el) -> el.findElements webdriver.By.css '.tooltip-inner'
    .then (els) ->
      actions =
        for el in els
          do (el) -> (cb) ->
            success = (text) ->
              el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id').then (id) ->
                errorMsgs[id] = text
                cb()
            el.getText().then success, -> cb("error") #needs to have a fail callback to be able to deal with stale elements
      Q.nfcall async.parallel, actions
    .then -> errorMsgs
  findElement: (selector) ->
    return selector unless typeof selector is 'string'
    d = Q.defer()
    @driver.findElement(webdriver.By.css(selector))
    .then ((el) -> d.fulfill el), (err) -> d.reject err
    d.promise
  findElements: (selector) -> Q @driver.findElements webdriver.By.css(selector)
  findElementIn: (selector, childSelector) ->
    @findElement(selector)
    .then (el) -> el.findElement webdriver.By.css childSelector
  findElementsIn: (selector, childrenSelector) ->
    @findElement(selector)
    .then (el) -> el.findElements webdriver.By.css childrenSelector
  clearCookies: -> Q(@driver.manage().deleteAllCookies()).then(->)
  type: (selector, text) ->
    text = "" unless text?
    @findElement selector
    .then (el) ->
      Q el.clear()
      .then -> el.sendKeys text
  selectWithValue: (selector, val) ->
    if val is ''
      return Q.fcall ->
    @findElement(selector)
    .then (el) -> el.findElements(webdriver.By.tagName('option'))
    .then (els) ->
      elsWithText = []
      flow = webdriver.promise.createFlow (f) ->
        for el in els
          do (el) -> f.execute -> el.getAttribute('value').then (val) -> elsWithText.push {val: val, el: el}
        undefined
      Q(flow).then -> _.findWhere(elsWithText, val:val).el.click()
  select: (selector, text) ->
    if text is ''
      return Q.fcall ->
    @findElement(selector)
    .then (el) -> el.findElements(webdriver.By.tagName('option'))
    .then (els) ->
      elsWithText = []
      flow = webdriver.promise.createFlow (f) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> elsWithText.push {text: text, el: el}
        undefined
      Q(flow).then -> _.findWhere(elsWithText, text:text).el.click()
  checkOrUncheck: (selector, check) ->
    if check
      @check selector
    else
      @uncheck selector
  check: (selector) ->
    @findElement selector
    .then (el) ->
      Q el.isSelected()
      .then (itIs) -> Q(el.click()) unless itIs
  uncheck: (selector) ->
    @findElement selector
    .then (el) ->
      Q el.isSelected()
      .then (itIs) -> Q(el.click()) if itIs
  getTextIn: (selector, childSelector) -> @findElementIn(selector, childSelector).then (el) => @getText el
  getAttributeInElements: (selector, attr) ->
    @findElements(selector)
    .then (els) =>
      getActions =
        for el in els
          do (el) =>
            (cb) => @getAttribute(el, attr).then (t) -> cb null, t
      Q.nfcall async.parallel, getActions
  getAttributeIn: (selector, childSelector, attr) ->
    @findElementIn selector, childSelector
    .then (el) => @getAttribute el, attr
  getTextIfExists: (selector) ->
    @hasElement selector
    .then (itHas) =>
      return null unless itHas
      @getText selector
  getText: (selector) -> @findElement(selector).then (el) -> el.getText()
  getTexts: (selector) ->
    texts = []
    flow = webdriver.promise.createFlow (f) =>
      @findElements(selector).then (els) ->
        for el in els
          do (el) -> f.execute -> el.getText().then (text) -> texts.push text
        undefined
    Q(flow).then -> texts
  getAttribute: (selector, attribute) -> @findElement(selector).then (el) -> el.getAttribute(attribute)
  getValue: @::getAttribute.partial undefined, 'value'
  getValueIn: @::getAttributeIn.partial undefined, undefined, 'value'
  getHrefIn: @::getAttributeIn.partial(undefined, undefined, 'href')
  getSrc: @::getAttribute.partial(undefined, 'src', undefined)
  getSrcIn: @::getAttributeIn.partial(undefined, undefined, 'src', undefined)
  getIsClickable: (selector) ->
    @isVisible selector
    .then (itIs) =>
      return false unless itIs
      @getIsEnabled selector
  getIsChecked: (selector) -> @findElement(selector).then (el) -> el.isSelected()
  getIsEnabled: (selector) -> @findElement(selector).then (el) -> el.isEnabled()
  pressButtonLegacy: (selector) -> @findElement(selector).then (el) -> el.click()
  pressButtonJS: (id) -> @eval "document.getElementById('#{id}').click()"
  click: (selector) -> @findElement(selector).then (el) -> el.click()
  clickAndWait: (selector) -> @click(selector).then @waitForAjax
  pressButton: (selector) -> @findElement(selector).then (el) -> el.sendKeys(webdriver.Key.ENTER)
  pressButtonAndWait: (selector) -> @pressButton(selector).then @waitForAjax
  clickLink: @::pressButton
  currentUrl: -> Q @driver.getCurrentUrl()
  hasElement: (selector) -> Q @driver.isElementPresent webdriver.By.css(selector)
  hasElementAndIsVisible: (selector) ->
    @hasElement selector
    .then (itHas) =>
      return false unless itHas
      @isVisible selector
  isVisible: (selector) -> @findElement(selector).then (el) -> el.isDisplayed()
  parallel: (actions) ->
    flow = webdriver.promise.createFlow (f) ->
      for action in actions
        do (action) -> f.execute action
      undefined
    Q flow
  waitForAjax: -> @wait (=> @eval 'return typeof($) !== \'undefined\' && $.active === 0;'), 5000
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
  waitForUrl: (url) -> @wait (=> @currentUrl().then((currentUrl) -> currentUrl is url)), 3000
  wait: (fn, timeout) -> Q(@driver.wait fn, timeout).then ->
  visitBlank: -> Q Page::visit.call @, 'blank', false
  loginFor: (_id) ->
    @currentUrl()
    .then (url) => @visitBlank() if url.substr(0,4) isnt 'http' #need the browser loaded to access cookies and have a session cookie id
    .then => @driver.manage().getCookie('connect.sid')
    .then (cookie) =>
      return cookie if cookie?
      @refresh().then => @driver.manage().getCookie('connect.sid')
    .then (cookie) ->
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
  eval: (script) -> Q @driver.executeScript(script)
  clearLocalStorage: ->
    @currentUrl()
    .then (url) => @visitBlank() if url.substr(0,4) isnt 'http' #need the browser loaded to access localstorage
    .then => @eval 'localStorage.clear()'
  refresh: -> Q @driver.navigate().refresh()
  reload: @::refresh
  getHtml: (selector) -> @findElement(selector).then (el) -> el.getOuterHtml()
  getPageHtml: -> @findElement('html').then (el) -> el.getOuterHtml()
  getInnerHtml: (selector) -> @findElement(selector).then (el) -> el.getInnerHtml()
  getDialogMsg: -> @waitForSelectorClickable('.dialogMsg').then => @getText '.dialogMsg'
  getDialogTitle: -> @waitForSelectorClickable('#dialogTitle').then => @getText '#dialogTitle'
  getDialogTexts: ->
    @waitForSelectorClickable '#dialogTitle'
    .then => @getText '.dialogMsg'
    .then (dialogMsg) =>
      @getText '#dialogTitle'
      .then (dialogTitle) -> dialogMsg: dialogMsg, dialogTitle: dialogTitle
  closeDialog: @::pressButton.partial ".dialogClose"
  getParent: (el) ->
    d = Q.defer()
    el.findElement(webdriver.By.xpath('..'))
    .then ((el) -> d.fulfill el), (err) -> d.reject err
    d.promise
  uploadFile: (selector, path) -> @findElement(selector).then (el) -> el.sendKeys path if path?
  waitForReady: -> @wait (=> @eval "return document.readyState === 'complete';"), 5000
  captureAttribute: captureAttribute
  resolveObj: (obj) ->
    cbObj = {}
    for key, promise of obj
      if Q.isPromiseAlike promise
        do (key, promise) ->
          cbObj[key] = (cb) ->
            Q(promise)
            .then (result) -> cb null, result
            .catch (err) -> cb err
    d = Q.defer()
    async.parallel cbObj, (err, resultObj) ->
      d.reject err if err?
      for key, value of resultObj
        obj[key] = value
      d.resolve obj
    d.promise
