Page          = require './seleniumPage'

module.exports = class AdminManageStorePage extends Page
  url: 'account/updateProfile'
  setFieldsAs: (user, cb) =>
    @type "#updateProfileForm #name", user.name
    @type "#updateProfileForm #deliveryStreet", user.deliveryAddress.street
    @type "#updateProfileForm #deliveryStreet2", user.deliveryAddress.street2
    @type "#updateProfileForm #deliveryCity", user.deliveryAddress.city
    @type "#updateProfileForm #deliveryZIP", user.deliveryAddress.zip
    @type "#updateProfileForm #phoneNumber", user.phoneNumber
    @checkOrUncheck "#updateProfileForm #isSeller", user.isSeller, =>
      if user.deliveryState isnt ''
        @select "#updateProfileForm #deliveryState", user.deliveryAddress.state, cb
      else
        cb()
  clickUpdateProfileButton: @::pressButton.partial "#updateProfile"
