module.exports = class Page
  constructor: (@browser, @url) ->
  visit: (url, options, cb) =>
    if typeof url == "function" && !options?
      [cb, url, options] = [url, null, null]
    else if typeof options == "function" && !cb?
      [cb, options] = [options, null]
    unless url?
      url = @url
    #console.log "opt:#{JSON.stringify options}, url:#{url}"
    @browser.visit "http://localhost:8000/#{url}", options, cb
