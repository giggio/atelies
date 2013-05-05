routes    = require './index'

exports.route = (app) ->
  app.get "/", routes.index
  app.get "/admin", routes.admin
  app.post "/admin/store", routes.adminStore
  app.get "/:storeSlug", routes.store
  app.get "/:storeSlug/:productSlug", routes.product
