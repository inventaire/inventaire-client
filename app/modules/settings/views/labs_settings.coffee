behaviorsPlugin = require 'modules/general/plugins/behaviors'

module.exports = Marionette.ItemView.extend
  template: require './templates/labs_settings'
  className: 'labsSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  events:
    'click a#booksJsonExport': 'itemsJsonExport'

  initialize: -> _.extend @, behaviorsPlugin

  itemsJsonExport: ->
    userInventory = app.items.personal.toJSON()
    username = app.user.get 'username'
    date = new Date().toLocaleDateString()
    name = "inventaire.io-#{username}-#{date}.json"
    _.openJsonWindow(userInventory, name)
