fs = require 'fs'
path = require 'path'
coffee = require 'coffee-script'
return if patched
patched = true

originalExistsSync = fs.existsSync
fs.existsSync = (fileName) ->
  exists = originalExistsSync fileName
  return true if exists
  ext = path.extname(fileName)
  return false if ext isnt '.js'
  coffeeFile = fileName.replace ///#{ext}$///, ".coffee"
  existsCoffee = originalExistsSync coffeeFile
  existsCoffee

originalReadFileSync = fs.readFileSync
fs.readFileSync = (fileName, opt) ->
  return originalReadFileSync fileName, opt unless _shouldPatch fileName
  exists = originalExistsSync fileName
  return originalReadFileSync fileName, opt if exists
  ext = path.extname(fileName)
  coffeeFile = fileName.replace ///#{ext}$///, ".coffee"
  existsCoffee = originalExistsSync coffeeFile
  if existsCoffee
    content = originalReadFileSync coffeeFile, opt
    compiledCoffee = coffee.compile content
    compiledCoffee
  else
    originalReadFileSync fileName, opt

originalRealpathSync = fs.realpathSync
fs.realpathSync = (fileName, cache) ->
  return originalRealpathSync fileName, cache unless _shouldPatch fileName
  exists = originalExistsSync fileName
  return originalRealpathSync fileName, cache if exists
  ext = path.extname(fileName)
  coffeeFile = fileName.replace ///#{ext}$///, ".coffee"
  existsCoffee = originalExistsSync coffeeFile
  originalRealpathSync coffeeFile, cache

_shouldPatch = (fileName) ->
  ext = path.extname(fileName)
  ext is '.js' and fileName.indexOf "/public/javascripts/" isnt -1
