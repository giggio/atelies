_         = require 'underscore'
Home      = require './home'
Account   = require './account'
Store     = require './store'
Admin     = require './admin'
SiteAdmin = require './siteAdmin'

exports.route = (app) ->
  env = app.get "env"
  domain = app.get 'domain'
  home = new Home env
  _.bindAll home
  store = new Store env, domain
  _.bindAll store
  account = new Account env
  _.bindAll account
  admin = new Admin env
  _.bindAll admin
  siteAdmin = new SiteAdmin env
  _.bindAll siteAdmin
  home.storeWithDomain = store.store
  #home
  app.get     "/",                                                          home.index domain
  app.get     "/blank",                                                     home.blank
  app.get     "/about",                                                     home.about
  app.get     "/terms",                                                     home.terms
  app.get     "/faq",                                                       home.faq
  app.get     "/technology",                                                home.technology
  app.get     "/iWantToBuy",                                                home.iWantToBuy
  app.get     "/iWantToSell",                                               home.iWantToSell
  app.get     "/contribute",                                                home.contribute
  app.get     "/donating",                                                  home.donating
  app.post    "/api/error",                                                 home.errorCreate
  app.get     "/humans.txt",                                                home.humanstxt
  #home client routes
  app.get     "/searchProducts/:searchTerm?",                               home.index domain
  app.get     "/searchStores/:searchTerm?",                                 home.index domain
  #home search
  app.get     "/api/stores/search/:searchTerm",                             home.storesSearch
  app.get     "/api/products/search/:searchTerm",                           home.productsSearch
  #account
  app.get     "/account/registered",                                        account.registered
  app.get     "/account/mustVerifyUser",                                    account.mustVerifyUser
  app.get     "/account/verifyUser/:_id",                                   account.verifyUser
  app.get     "/account/verified",                                          account.verified
  app.get     "/api/account/orders/:_id",                                   account.order
  app.post    "/api/account/orders/:_id/evaluation",                        account.evaluationCreate
  app.get     "/account/changePassword",                                    account.changePasswordShow
  app.post    "/account/changePassword",                                    account.changePassword
  app.get     "/account/passwordChanged",                                   account.passwordChanged
  app.get     "/account/updateProfile",                                     account.updateProfileShow
  app.post    "/account/updateProfile",                                     account.updateProfile
  app.get     "/account/profileUpdated",                                    account.profileUpdated
  app.get     "/account/forgotPassword",                                    account.forgotPasswordShow
  app.post    "/account/forgotPassword",                                    account.forgotPassword
  app.get     "/account/passwordResetSent",                                 account.passwordResetSent
  app.get     "/account/resetPassword",                                     account.resetPasswordShow
  app.post    "/account/resetPassword",                                     account.resetPassword
  app.post    "/api/account/resendConfirmationEmail",                       account.resendConfirmationEmail
  app.get     "/account/afterFacebookLogin",                                account.afterFacebookLogin
  app.get     "/account",                                                   account.redirectAddingDash
  app.get     /account\/.*/,                                                account.account
  app.get     "/notseller",                                                 account.notSeller
  #site admin
  app.get     "/siteAdmin",                                                 siteAdmin.redirectAddingDash
  app.get     /^\/siteAdmin\/.*/,                                           siteAdmin.siteAdmin
  app.get     "/api/siteAdmin/storesForAuthorization/:isFlyerAuthorized?",  siteAdmin.storesForAuthorization
  app.put     "/api/siteAdmin/storesForAuthorization/:_id/isFlyerAuthorized/:isFlyerAuthorized", siteAdmin.updateStoreFlyerAuthorization
  #admin
  app.get     "/api/admin/orders",                                          admin.orders
  app.get     "/api/admin/orders/:_id",                                     admin.order
  #admin store
  app.post    "/api/admin/store",                                           admin.adminStoreCreate
  app.put     "/api/admin/store/:storeId",                                  admin.adminStoreUpdate
  app.put     "/api/admin/store/:storeId/setPagseguroOn",                   admin.adminStoreUpdateSetPagseguroOn
  app.put     "/api/admin/store/:storeId/setPagseguroOff",                  admin.adminStoreUpdateSetPagseguroOff
  #admin product
  app.get     "/api/admin/:storeSlug/products",                             admin.storeProducts
  app.post    "/api/admin/:storeSlug/products",                             admin.adminProductCreate
  app.get     "/api/admin/:storeSlug/products/:productId",                  admin.storeProduct
  app.put     "/api/admin/:storeSlug/products/:productId",                  admin.adminProductUpdate
  app.delete  "/api/admin/:storeSlug/products/:productId",                  admin.adminProductDelete
  app.get     "/api/admin/:storeId/categories",                             admin.storeCategories
  app.get     "/admin",                                                     admin.redirectAddingDash
  app.get     /admin\/.*/,                                                  admin.admin
  #store order
  app.post    "/api/orders/:storeId",                                       store.orderCreate
  app.get     "/paymentGateway/pagseguro/:storeSlug/returnFromPayment",     store.pagseguroReturnFromPayment
  app.post    "/api/paymentGateway/pagseguro/:storeSlug/statusChanged",     store.pagseguroStatusChanged
  app.post    "/api/shipping/:storeSlug",                                   store.calculateShipping
  #store
  app.get     "/api/products/search/:storeSlug/:searchTerm",                store.productsSearch
  app.post    "/api/products/:productId/comments",                          store.commentCreate
  app.get     "/api/stores/:_id/evaluations",                               store.evaluations
  app.get     "/api/:storeSlug/:productSlug",                               store.product
  app.get     "/:storeSlug",                                                store.redirectAddingDash
  app.get     "/:storeSlug/*",                                              store.store
  #store client routes
  app.get     "/:storeSlug/searchProducts/:searchTerm?",                    store.store
