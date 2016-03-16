behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ apiDoc } = require 'lib/urls'
{ host } = window.location

module.exports = Marionette.ItemView.extend
  template: require './templates/labs_settings'
  className: 'labsSettings'
  behaviors:
    AlertBox: {}
    SuccessCheck: {}
    Loading: {}

  events:
    'click a#userJsonExport': 'userJsonExport'
    'click a#itemsJsonExport': 'itemsJsonExport'

  initialize: -> _.extend @, behaviorsPlugin

  serializeData: ->
    apiDoc: apiDoc
    endpoints: endpointsData app.user.get('username')

  itemsJsonExport: -> openDownloadPage app.items.personal.toJSON(), 'items'
  userJsonExport: -> openDownloadPage app.user.toJSON(), 'user'

openDownloadPage = (data, label)->
  username = app.user.get 'username'
  date = new Date().toLocaleDateString()
  name = "inventaire.io-#{username}-#{label}-#{date}.json"
  _.openJsonWindow data, name

endpointDemo = (username, endpoint)->
  "$ curl #{location.protocol}//#{username}:yourpassword@#{host}/api/#{endpoint}"

endpointsData = (username)->
  user: endpointDemo username, 'user'
  items: endpointDemo username, 'items'
