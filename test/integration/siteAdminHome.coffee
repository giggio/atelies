require './support/_specHelper'
SiteAdminHomePage                = require './support/pages/siteAdminHomePage'

describe 'Site Admin home page', ->
  page = regularUser = adminUser = superAdmin = null
  before (done) ->
    cleanDB (error) ->
      return done error if error
      page = new SiteAdminHomePage()
      regularUser = generator.user.a()
      regularUser.save()
      superAdmin = generator.user.superAdmin()
      superAdmin.save()
      adminUser = generator.user.a()
      adminUser.isAdmin = true
      adminUser.save()
      whenServerLoaded done

  describe 'accessing with a non admin (regular) user', ->
    before (done) ->
      page.loginFor regularUser._id, ->
        page.visit done
    it 'shows access denied message', (done) ->
      page.accessDeniedMessageIsVisible (itIs) -> itIs.should.be.true; done()

  describe 'accessing with a admin user allows access', ->
    before (done) ->
      page.loginFor adminUser._id, ->
        page.visit done
    it 'allows access', (done) ->
      page.accessDeniedMessageIsVisible (itIs) -> itIs.should.be.false; done()

  describe 'accessing with super admin user', ->
    before (done) ->
      page.loginFor superAdmin._id, ->
        page.visit done
    it 'allows access', (done) ->
      page.accessDeniedMessageIsVisible (itIs) -> itIs.should.be.false; done()
