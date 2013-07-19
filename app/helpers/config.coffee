unless process.env.NODE_ENV is 'production'
  process.env.BASE_DOMAIN = 'localhost.com'
  process.env.AWS_IMAGES_BUCKET = "ateliesteste"
  process.env.AWS_REGION = "us-east-1"
  process.env.APP_COOKIE_SECRET = 'somesecret'

values =
  appCookieSecret: process.env.APP_COOKIE_SECRET
  connectionString: process.env.MONGOLAB_URI
  port: process.env.PORT
  environment: process.env.NODE_ENV
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
  baseDomain: process.env.BASE_DOMAIN
values.allValuesPresent = ->
  @appCookieSecret? and @connectionString? and @port? and @environment? and
    @aws? and @aws?.accessKeyId? and @aws?.secretKey? and @aws?.region? and @aws?.imagesBucket? and
    @recaptcha? and @recaptcha?.publicKey? and @recaptcha?.privateKey and @baseDomain?
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
  baseDomain: values.baseDomain?
console.log "Config values present: #{JSON.stringify valuesPresent}"
console.log "Config values: #{JSON.stringify values}" if values.debug
throw new Error("Missing config values.") if values.allValuesPresent() is false and values.debug is off and values.environment isnt 'test'
module.exports = values
