{ BasicPlugin } = require 'lib/plugins'

handlers =
  itemShow: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item', @model

  showUser: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:user', @model
      # Required to close the ItemShow modal if one was open
      app.execute 'modal:close'

  showTransaction: (e)->
    unless _.isOpenedOutside e
      transac = app.request 'get:transaction:ongoing:byItemId', @model.id
      app.execute 'show:transaction', transac.id
      # Required to close the ItemShow modal if one was open
      app.execute 'modal:close'

events =
  'click a.itemShow': 'itemShow'
  'click a.user': 'showUser'
  'click a.userShow': 'showUser'
  'click a.mainUserRequested': 'showTransaction'

module.exports = BasicPlugin events, handlers
