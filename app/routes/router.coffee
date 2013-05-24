routes    = require './index'

exports.route = (app) ->
  app.get     "/",                                                          routes.index
  app.get     "/notseller",                                                 routes.notSeller
  app.get     "/admin",                                                     routes.admin
  app.post    "/admin/store",                                               routes.adminStore
  app.get     "/admin/:storeSlug/products",                                 routes.storeProducts
  app.post    "/admin/:storeSlug/products",                                 routes.adminProductCreate
  app.get     "/admin/:storeSlug/products/:productId",                      routes.storeProduct
  app.put     "/admin/:storeSlug/products/:productId",                      routes.adminProductUpdate
  app.delete  "/admin/:storeSlug/products/:productId",                      routes.adminProductDelete
  app.get     "/:storeSlug",                                                routes.store
  app.get     "/:storeSlug/:productSlug",                                   routes.product
