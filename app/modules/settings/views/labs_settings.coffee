module.exports = class LabsSettings extends Backbone.Marionette.ItemView
  template: require './templates/labs_settings'
  events:
    'click a#dataExport': 'dataExport'

  dataExport: ->
    userInventory = Items.personal.toJSON()
    username = app.user.get 'username'
    date = new Date().toLocaleDateString()
    name = "inventaire.io-#{username}-#{date}.json"
    _.openJsonWindow(userInventory, name)
