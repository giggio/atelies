Routes    = require './index'

exports.route = (app) ->
  routes = new Routes app.get "env"
  domain = app.get 'domain'
  app.get     "/",                                                          routes.index domain
  #order
  app.post    "/orders/:storeId",                                           routes.orderCreate
  #search
  app.get     "/stores/search/:searchTerm",                                 routes.storesSearch
  app.get     "/products/search/:searchTerm",                               routes.productsSearch
  #misc
  app.get     "/blank",                                                     routes.blank
  #account
  app.get     "/account",                                                   routes.account
  app.get     "/account/orders/:_id",                                       routes.order
  app.get     "/account/changePassword",                                    routes.changePasswordShow
  app.post    "/account/changePassword",                                    routes.changePassword
  app.get     "/account/passwordChanged",                                   routes.passwordChanged
  app.get     "/account/updateProfile",                                     routes.updateProfileShow
  app.post    "/account/updateProfile",                                     routes.updateProfile
  app.get     "/account/profileUpdated",                                    routes.profileUpdated
  app.get     "/notseller",                                                 routes.notSeller
  #admin
  app.get     "/admin",                                                     routes.admin
  #admin store
  app.post    "/admin/store",                                               routes.adminStoreCreate
  app.put     "/admin/store/:storeId",                                      routes.adminStoreUpdate
  #admin product
  app.get     "/admin/:storeSlug/products",                                 routes.storeProducts
  app.post    "/admin/:storeSlug/products",                                 routes.adminProductCreate
  app.get     "/admin/:storeSlug/products/:productId",                      routes.storeProduct
  app.put     "/admin/:storeSlug/products/:productId",                      routes.adminProductUpdate
  app.delete  "/admin/:storeSlug/products/:productId",                      routes.adminProductDelete
  #store
  app.get     "/:storeSlug",                                                routes.store domain
  app.get     "/:storeSlug/:productSlug",                                   routes.product
