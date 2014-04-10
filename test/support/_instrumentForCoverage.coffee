path = require 'path'
appDir = path.join __dirname, '..', '..', 'app'
require('blanket')
  pattern: appDir
