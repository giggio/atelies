fs            = require 'fs'
path          = require 'path'
http          = require 'http'
https         = require 'https'
child_process = require 'child_process'

process.addListener 'uncaughtException', (error) -> console.log "Error happened:\n#{error.stack}"
process.stdout.setMaxListeners(100)
process.stderr.setMaxListeners(100)
iswin = process.platform is 'win32'
currDir = __dirname
if iswin and currDir.substring(0,2) is "\\\\"
  depTarget = process.env.DEPLOYMENT_TARGET
  currDir = depTarget
coffee = path.join currDir,  "node_modules", "coffee-script", "bin", "coffee"

compileDirectory = (dirPath) ->
  for dirItem in fs.readdirSync(dirPath)
    fullItemPath = path.join dirPath, dirItem
    continue unless fs.existsSync fullItemPath
    isDirectory =  fs.statSync(fullItemPath).isDirectory()
    if isDirectory
      compileDirectory fullItemPath unless dirItem is 'node_modules'
    else
      compileFile fullItemPath

isACoffeeFile = (file) -> file.indexOf(".coffee", file.length - 7) isnt -1

compileFile = (file) ->
  return unless isACoffeeFile file
  console.log "found file #{file}, compiling..."
  coffeeProcess = child_process.spawn 'node', [coffee, '--compile', file], { cwd: currDir, env: process.env }
  coffeeProcess.stdout.pipe process.stdout
  coffeeProcess.stderr.pipe process.stderr
  coffeeProcess.on 'error', (err) =>
    console.log "Error compiling file #{file}."
    throw err

publicJSPath     = (file) -> path.join(currDir, 'public', 'javascripts', 'lib', file)
publicCSSPath    = (file) -> path.join(currDir, 'public', 'stylesheets', 'lib', file)
publicImagesPath = (file) -> path.join(currDir, 'public', 'images', 'lib', file)

downloadFileToJS = (remoteFile, fileName, options) ->
  if !options and (typeof fileName is 'object')
    options = fileName
    fileName = undefined
  fileName = path.basename remoteFile if fileName is undefined
  localFile = publicJSPath fileName
  downloadFile remoteFile, localFile, options

downloadFileToCSS = (remoteFile, fileName, options) ->
  if !options and (typeof fileName is 'object')
    options = fileName
    fileName = undefined
  fileName = path.basename remoteFile if fileName is undefined
  localFile = publicCSSPath fileName
  downloadFile remoteFile, localFile, options

downloadFileToImages = (remoteFile, fileName, options) ->
  if !options and (typeof fileName is 'object')
    options = fileName
    fileName = undefined
  fileName = path.basename remoteFile if fileName is undefined
  localFile = publicImagesPath fileName
  downloadFile remoteFile, localFile, options

downloadFile = (remoteFile, localFile, options) ->
  console.log "downloading file #{path.basename localFile}..."
  options.waitingDownload = 0 unless options.waitingDownload
  shouldDownload = !(fs.existsSync localFile) or (options.buildForce is on)
  return unless shouldDownload
  options.waitingDownload++
  directory = path.dirname localFile
  fs.mkdirSync directory unless fs.existsSync directory
  file = fs.createWriteStream localFile
  getter = if remoteFile.substring(0,5) is 'https' then https else http
  request = getter.get(remoteFile, (response) ->
    response.pipe file
    options.waitingDownload--
  ).on 'error', (err) ->
    options.waitingDownload--
    console.log "Error when getting #{remoteFile}:\n#{err.stack}"


whenDone = (condition, callback) ->
  if condition()
    callback()
  else
    setTimeout((-> whenDone(condition, callback)), 1000)

task 'test', 'Build single application file from source files', (options) ->
  invoke 'dependencies:npmfull'
  invoke 'compile:coffee'
  invoke 'dependencies:js'
  whenDone (-> options.npmProcessInstallDone), -> invoke 'run:test'

task 'build', 'Build single application file from source files', (options) ->
  invoke 'dependencies:npm'
  invoke 'compile:coffee'
  invoke 'dependencies:js'

task 'build:force', 'Build single application file from source files and download again existing dependencies', (options) ->
  options.buildForce = on
  invoke 'build'

task 'run:test', 'Runs the tests', (options) ->
  console.log 'Running tests via npm...'
  npmProcessTest = child_process.spawn 'npm', ['test'], { cwd: currDir, env: process.env }
  npmProcessTest.stdout.pipe process.stdout
  npmProcessTest.stderr.pipe process.stderr
  npmProcessTest.on 'exit', => options.npmProcessTestDone = on
  npmProcessTest.on 'error', (err) =>
    console.log "Error when running tests (npm test)"
    options.npmProcessTestDone = on
    throw err

task 'dependencies:npmfull', 'Run npm (full)', (options) ->
  console.log 'Installing npm packages (full)...'
  options.npmProcessInstallDone = off
  npmProcessInstall = child_process.spawn 'npm', ['install'], { cwd: currDir, env: process.env }
  npmProcessInstall.stdout.pipe process.stdout
  npmProcessInstall.stderr.pipe process.stderr
  npmProcessInstall.on 'exit', (code) =>
    console.log "Completed npm installation with exit code #{code}."
    options.npmProcessInstallDone = on
  npmProcessInstall.on 'error', (err) =>
    console.log "Error when running npm install (full)"
    options.npmProcessInstallDone = on
    throw err

task 'dependencies:npm', 'Run npm (only production)', (options) ->
  console.log 'Installing npm packages (production)...'
  npmProcessInstall = child_process.spawn 'npm', ['install', '--production'], { cwd: currDir, env: process.env }
  npmProcessInstall.stdout.pipe process.stdout
  npmProcessInstall.stderr.pipe process.stderr
  npmProcessInstall.on 'exit', (code) =>
    console.log "Completed npm installation with exit code #{code}."
    options.npmProcessInstallDone = on
  npmProcessInstall.on 'error', (err) =>
    console.log "Error when running npm install (production)"
    options.npmProcessInstallDone = on
    throw err

task 'compile:coffee', 'compiles CoffeeScript files', ->
  compileDirectory currDir

task 'dependencies:js', 'copies js dependencies to public/script', (options) ->
  downloadFileToJS      "http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js", options
  downloadFileToJS      "http://ajax.googleapis.com/ajax/libs/jqueryui/1.10.2/jquery-ui.min.js", options
  downloadFileToJS      "http://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.4.4/underscore-min.js", options
  downloadFileToJS      "http://cdnjs.cloudflare.com/ajax/libs/backbone.js/1.0.0/backbone-min.js", options
  downloadFileToCSS     "http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/css/bootstrap.min.css", options
  downloadFileToCSS     "http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/css/bootstrap-responsive.min.css", options
  downloadFileToJS      "http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/js/bootstrap.min.js", options
  downloadFileToCSS     "http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/img/glyphicons-halflings-white.png", path.join("img", "glyphicons-halflings-white.png"), options
  downloadFileToCSS     "http://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/2.3.1/img/glyphicons-halflings.png", path.join("img", "glyphicons-halflings.png"), options
  downloadFileToJS      "http://cdnjs.cloudflare.com/ajax/libs/require.js/2.1.5/require.min.js", options
  downloadFileToJS      "http://cdnjs.cloudflare.com/ajax/libs/require-text/2.0.5/text.js", options
  downloadFileToJS      "http://cdnjs.cloudflare.com/ajax/libs/handlebars.js/1.0.0-rc.3/handlebars.min.js", options
  downloadFileToJS      'https://raw.github.com/requirejs/text/master/text.js', options
  downloadFileToJS      'http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/jquery.validate.min.js', options
  downloadFileToJS      'http://ajax.aspnetcdn.com/ajax/jquery.validate/1.11.1/additional-methods.min.js', options
  downloadFileToJS      'https://raw.github.com/theironcook/Backbone.ModelBinder/9ffd7f83e53a04863049631833152df8647f0829/Backbone.ModelBinder.js', options
  downloadFileToJS      'https://cdnjs.cloudflare.com/ajax/libs/backbone.validation/0.7.1/backbone-validation-amd-min.js', options
  whenDone((->
    waiting = options.waitingDownload
    waiting == 0), ->)