UserProfile = require 'modules/inventory/views/user_profile'

module.exports = Marionette.LayoutView.extend
  id: 'inventoryUserNav'
  template: require './templates/inventory_user_nav'
  regions:
    userProfile: '#userProfile'

  onShow: ->
    @userProfile.show new UserProfile { model: app.user }
