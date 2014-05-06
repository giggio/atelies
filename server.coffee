if process.env.NODE_ENV isnt 'production'
  coffee = require('coffee-script')
  coffee.register()
app = require('./app/app')
app.start()
