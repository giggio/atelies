push-location $PSScriptRoot
coffee -c basic.coffee
mongo --nodb --eval "var server='localhost', dbName='atelies';" "basic.js"
pop-location