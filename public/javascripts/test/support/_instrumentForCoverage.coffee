path = require 'path'
appDir = path.join __dirname, '..', '..'
require('blanket')
  pattern: appDir
