webdriver       = require 'selenium-webdriver'
connectUtils    = require 'connect/lib/utils'
_               = require 'underscore'
Q               = require 'q'
config          = require '../../../../app/helpers/config'
fs              = require 'fs'
path            = require 'path'
slug            = require '../../../../app/helpers/slug'
writeFile = Q.denodeify fs.writeFile
mkdir = Q.denodeify fs.mkdir
verbose = config.test.verbose

useChrome = on

before ->
  if useChrome
    write "seleniumPage.before: starting webdriver with chrome".cyan
    if config.test.snapci
      chromedriverPath = '/usr/local/bin/chromedriver'
    else
      chromedriver = require 'chromedriver'
      chromedriverPath = chromedriver.path
    write "seleniumPage.before: got chromedriver path: '#{chromedriverPath}'".cyan
    chrome = require "selenium-webdriver/chrome"
    chromeServiceBuilder = new chrome.ServiceBuilder chromedriverPath
    #chromeServiceBuilder
    #  .loggingTo('/tmp/chromedriver.log')
    #  .enableVerboseLogging()
    chromeServiceBuilder.args_.push "--whitelisted-ips"
    capabilities = webdriver.Capabilities.chrome()
    capabilities.set 'chromeOptions',
      'prefs': {"profile.default_content_settings": {'images': 2}}
      'args': ["--host-rules=MAP * 127.0.0.1", '--test-type']
    service = chromeServiceBuilder.build()
    Page.driver = new chrome.Driver capabilities, service
  else
    write "seleniumPage.before: starting webdriver with phantom".cyan
    phantomjs = require 'phantomjs'
    capabilities = webdriver.Capabilities.phantomjs()
    capabilities.set 'phantomjs.binary.path', phantomjs.path
    Page.driver = new webdriver.Builder()
      .withCapabilities(capabilities)
      .build()
  write "seleniumPage.before: webdriver started".cyan
  Page.driver.manage().timeouts().implicitlyWait 2000

after -> Page.driver?.quit()

mkdirParent = (dirPath, mode) ->
  mkdir dirPath, mode
  .catch (error) ->
    if error.errno is 34
      mkdirParent path.dirname(dirPath), mode
      mkdirParent dirPath, mode
    else
      throw error

onTestError (title, err) ->
  return unless Page.driver?
  Q Page.driver.takeScreenshot()
  .then (base64) ->
    errMessage = if err.message? then '_' + slug(err.message) else ''
    fileName = path.join __dirname, '../../../../', 'log', new Date().valueOf() + '_' + slug(title) + errMessage + '.png'
    dir = path.dirname fileName
    Q.fcall -> unless fs.existsSync dir then mkdirParent dir
    .then ->
      console.log "Test failed, writing screenshot at '#{fileName}'."
      writeFile fileName, new Buffer(base64, 'base64')
  .catch (err) -> console.log "error saving file: ", err

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
    .then -> write "visit: got 'data:,".cyan
    .then => @driver.get(url)
    .then -> write "visit: got '#{url}'".cyan
    .then => @refresh() if refresh
    .then -> if refresh then write "visit: refreshed".cyan
  waitForViewToLoad: -> @wait (=> @eval "return window.renderDone === true;"), 5000
  waitForValidatorToLoad: -> @wait (=> @eval "return window.jQuery != null && window.jQuery.validator != null;"), 5000
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
          do (el) ->
            el.getText()
            .then (text) -> #, -> cb("error") #needs to have a fail callback to be able to deal with stale elements
              el.findElement(webdriver.By.xpath('../preceding-sibling::input[1]')).getAttribute('id')
              .then (id) -> errorMsgs[id] = text
      Q.all actions
    .then -> errorMsgs
  findElement: (selector) ->
    return Q(selector) unless typeof selector is 'string'
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
      write "type: clearing text".cyan
      Q el.clear()
      .then ->
        write "type: typing on '#{selector}' text '#{text}'".cyan
        el.sendKeys text
  typeWithJS: (selector, text) ->
    text = "" unless text?
    @waitForSelector selector #wait until found
    .then => @eval "document.querySelector('#{selector}').value = '#{text}';"
    .then => @eval "document.querySelector('#{selector}').blur();"
    .then => @eval "document.querySelector('#{selector}').dispatchEvent(new Event('change'));"
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
          do (el) => @getAttribute el, attr
      Q.all getActions
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
  pressButton: (selector) ->
    write "pressButton: pressing '#{selector}'".cyan
    @findElement(selector)
    .then (el) -> el.sendKeys(webdriver.Key.ENTER)
    .then -> write "pressButton: button pressed".cyan
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
  waitForAjax: ->
    write "waitForAjax: waiting for ajax".cyan
    @wait (=> @eval 'return typeof($) !== \'undefined\' && $.active === 0;'), 5000
    .then -> write "waitForAjax: wait done".cyan
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
      write "loginFor: got existing cookie".cyan if cookie?
      return cookie if cookie?
      write "loginFor: refreshing for cookie".cyan
      @refresh().then => @driver.manage().getCookie('connect.sid')
    .then (cookie) ->
      write "loginFor: got cookie".cyan
      server = getExpressServer()
      sessionStore = server.sessionStore
      cookieSecret = server.cookieSecret
      sessionId = connectUtils.parseSignedCookie decodeURIComponent(cookie.value), cookieSecret
      Q.ninvoke sessionStore, 'get', sessionId
      .then (session) ->
        write "loginFor: got session".cyan
        session.auth = {} unless session.auth?
        session.auth.userId = _id
        session.auth.loggedIn = true
        Q.ninvoke sessionStore, 'set', sessionId, session
    .then -> write "loginFor: saved on session store, now waiting".cyan
    .then -> waitMilliseconds 200
    .then -> write "loginFor: wait done".cyan
  eval: (script) -> Q @driver.executeScript(script)
  clearLocalStorage: ->
    @currentUrl()
    .then (url) => @visitBlank() if url.substr(0,4) isnt 'http' #need the browser loaded to access localstorage
    .then => @eval 'localStorage.clear()'
  refresh: -> Q @driver.navigate().refresh()
  reload: @::refresh
  getHtml: (selector) -> @findElement(selector).then (el) -> el.getOuterHtml()
  getPageHtml: -> @findElement('html').then (el) -> el.getOuterHtml()
  printPageHtml: -> @getPageHtml().then (html) -> print html
  printPageHtmlWithJS: -> @eval("return document.querySelector('html').outerHTML;").then (html) -> print html
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
    promises = for key, promise of obj
      obj[key] = Q promise
    Q.all promises
    .then (results) ->
      retObj = {}
      for key, promise of obj
        retObj[key] = promise.valueOf()
      retObj
