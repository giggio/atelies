require './support/_specHelper'
SiteAdminHomePage                = require './support/pages/siteAdminHomePage'
Q                                = require 'q'

describe 'Site Admin home page', ->
  page = regularUser = adminUser = superAdmin = null
  before ->
    cleanDB().then ->
      page = new SiteAdminHomePage()
      regularUser = generator.user.a()
      superAdmin = generator.user.superAdmin()
      adminUser = generator.user.a()
      adminUser.isAdmin = true
      Q.all [Q.ninvoke(regularUser, 'save'), Q.ninvoke(superAdmin, 'save'), Q.ninvoke(adminUser, 'save') ]

  describe 'accessing with a non admin (regular) user', ->
    before ->
      page.loginFor regularUser._id
      .then page.visit
    it 'shows access denied message', -> page.accessDeniedMessageIsVisible().should.eventually.be.true

  describe 'accessing with a admin user allows access', ->
    before ->
      page.loginFor adminUser._id
      .then page.visit
    it 'allows access', -> page.accessDeniedMessageIsVisible().should.eventually.be.false

  describe 'accessing with super admin user', ->
    before ->
      page.loginFor superAdmin._id
      .then page.visit
    it 'allows access', -> page.accessDeniedMessageIsVisible().should.eventually.be.false
