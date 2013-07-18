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
  recaptcha:
    publicKey: process.env.RECAPTCHA_PUBLIC_KEY
    privateKey: process.env.RECAPTCHA_PRIVATE_KEY
  test:
    sendMail: process.env.SEND_MAIL?
values.allValuesPresent = ->
  @appCookieSecret? and @connectionString? and @port? and @environment? and
    @aws? and @aws?.accessKeyId? and @aws?.secretKey? and @aws?.region? and
    @recaptcha? and @recaptcha?.publicKey? and @recaptcha?.privateKey
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
  recaptcha:
    publicKey: values.recaptcha?.publicKey?
    privateKey: values.recaptcha?.privateKey?
  test:
    sendMail: values.test?.sendMail?
console.log "Config values present: #{JSON.stringify valuesPresent}"
console.log "Config values: #{JSON.stringify values}" if values.debug
throw new Error("Missing config values.") if values.allValuesPresent() is false and values.debug is off
module.exports = values
