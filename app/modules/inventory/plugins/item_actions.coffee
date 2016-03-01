handlers =
  itemShow: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item:show:from:model', @model

  showUser: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:user', @model.username

  showTransaction: (e)->
    unless _.isOpenedOutside e
      transac = app.request 'get:transaction:ongoing:byItemId', @model.id
      app.execute 'show:transaction', transac.id

events =
  'click a.itemShow': 'itemShow'
  'click a.user': 'showUser'
  'click a.userShow': 'showUser'
  'click a.mainUserRequested': 'showTransaction'

module.exports = _.BasicPlugin events, handlers
