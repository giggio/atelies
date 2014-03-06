Page          = require './seleniumPage'

module.exports = class AdminManageStorePage extends Page
  url: 'account/updateProfile'
  setFieldsAs: (user) =>
    @type "#updateProfileForm #name", user.name
    .then => @type "#updateProfileForm #deliveryStreet", user.deliveryAddress.street
    .then => @type "#updateProfileForm #deliveryStreet2", user.deliveryAddress.street2
    .then => @type "#updateProfileForm #deliveryCity", user.deliveryAddress.city
    .then => @type "#updateProfileForm #deliveryZIP", user.deliveryAddress.zip
    .then => @type "#updateProfileForm #phoneNumber", user.phoneNumber
    .then => @checkOrUncheck "#updateProfileForm #isSeller", user.isSeller
    .then => @select("#updateProfileForm #deliveryState", user.deliveryAddress.state) if user.deliveryState isnt ''
  clickUpdateProfileButton: @::pressButton.partial "#updateProfile"
