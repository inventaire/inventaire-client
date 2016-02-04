{ bitcoin, gratipay } = require 'lib/urls'

module.exports = Marionette.ItemView.extend
  template: require './templates/donate_menu'
  className: 'donate-menu'
  behaviors:
    General: {}
  onShow: -> app.execute 'modal:open'
  serializeData: ->
    bitcoin: bitcoin
