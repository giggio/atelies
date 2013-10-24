pkgInfo = require '../../package.json'
unless process.env.NODE_ENV is 'production'
  process.env.BASE_DOMAIN = 'localhost.com' unless process.env.BASE_DOMAIN?
  process.env.AWS_IMAGES_BUCKET = "ateliesteste"
  process.env.AWS_REGION = "us-east-1"
  process.env.APP_COOKIE_SECRET = 'somesecret'
  process.env.SERVER_ENVIRONMENT = 'dev'
  process.env.STATIC_PATH = '/public' unless process.env.STATIC_PATH?
  process.env.RECAPTCHA_PUBLIC_KEY = '6LfzS-QSAAAAAP3ydudINWrhwGAo-X0Vg86F6hf3'
  process.env.RECAPTCHA_PRIVATE_KEY = 'what' unless process.env.RECAPTCHA_PRIVATE_KEY?
  process.env.FB_APP_ID = '618886944811863'
  process.env.FB_APP_SECRET = '0cd3ee557fd385e31fdd065616347e1d'
  process.env.SUPER_ADMIN_EMAIL = "admin@atelies.com.br"
  process.env.CLIENT_LIB_VERSION = "."
  process.env.UPLOAD_FILES = true unless process.env.UPLOAD_FILES?
switch process.env.NODE_ENV
  when 'development'
    process.env.MONGOLAB_URI = "mongodb://localhost/atelies"
    process.env.PORT = 3000 unless process.env.PORT?
  when 'test'
    process.env.MONGOLAB_URI = "mongodb://localhost/ateliesteste"
    process.env.PORT = 8000 unless process.env.PORT?

values =
  appCookieSecret: process.env.APP_COOKIE_SECRET
  connectionString: process.env.MONGOLAB_URI
  port: process.env.PORT
  environment: process.env.NODE_ENV
  isProduction: process.env.NODE_ENV is 'production'
  debug: process.env.DEBUG? and process.env.DEBUG
  aws:
    accessKeyId: process.env.AWS_ACCESS_KEY_ID
    secretKey: process.env.AWS_SECRET_KEY
    region: process.env.AWS_REGION
    imagesBucket: process.env.AWS_IMAGES_BUCKET
  recaptcha:
    publicKey: process.env.RECAPTCHA_PUBLIC_KEY
    privateKey: process.env.RECAPTCHA_PRIVATE_KEY
  test:
    sendMail: process.env.SEND_MAIL?
    uploadFiles: process.env.UPLOAD_FILES?
  baseDomain: process.env.BASE_DOMAIN
  serverEnvironment: process.env.SERVER_ENVIRONMENT
  app:
    version: pkgInfo.version
    name: pkgInfo.name
  staticPath: process.env.STATIC_PATH
  facebook:
    appId: process.env.FB_APP_ID
    appSecret: process.env.FB_APP_SECRET
  superAdminEmail: process.env.SUPER_ADMIN_EMAIL?.toLowerCase()
  clientLibVersion: process.env.CLIENT_LIB_VERSION
  clientLibPath: "#{process.env.STATIC_PATH}/javascripts/#{process.env.CLIENT_LIB_VERSION}"
values.secureUrl = if values.environment is 'production' then "https://www.#{values.baseDomain}" else ""
values.allValuesPresent = ->
  @appCookieSecret? and @connectionString? and @port? and @environment? and
    @aws? and @aws?.accessKeyId? and @aws?.secretKey? and @aws?.region? and @aws?.imagesBucket? and
    @recaptcha? and @recaptcha?.publicKey? and @recaptcha?.privateKey and @baseDomain? and @serverEnvironment? and
    @staticPath? and @clientLibVersion? and @superAdminEmail?
valuesPresent =
  appCookieSecret: values.appCookieSecret?
  connectionString: values.connectionString?
  port: values.port?
  environment: values.environment?
  debug: values.debug?
  aws:
    accessKeyId: values.aws?.accessKeyId?
    secretKey: values.aws?.secretKey?
    region: values.aws?.region?
    imagesBucket: values.aws?.imagesBucket?
  recaptcha:
    publicKey: values.recaptcha?.publicKey?
    privateKey: values.recaptcha?.privateKey?
  test:
    sendMail: values.test?.sendMail?
    uploadFiles: values.test?.uploadFiles?
  baseDomain: values.baseDomain?
  serverEnvironment: values.serverEnvironment?
  staticPath: values.staticPath?
  clientLibVersion: values.clientLibVersion?
  superAdminEmail: values.superAdminEmail?
unless values.environment is 'test'
  console.log "Config values present: #{JSON.stringify valuesPresent}"
  console.log "Config values: #{JSON.stringify values}"
if values.allValuesPresent() is false and values.debug is off and values.environment isnt 'test'
  missing = []
  checkValues = (o) ->
    for k, v of o
      if typeof v is 'object'
        checkValues v
      else
        missing.push k unless v
  checkValues valuesPresent
  throw new Error("Missing config values: #{missing.join()}.")
module.exports = values
