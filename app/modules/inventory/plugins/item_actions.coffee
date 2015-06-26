handlers =
  itemShow: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:item:show:from:model', @model

  showUser: (e)->
    unless _.isOpenedOutside(e)
      app.execute 'show:user', @model.username

events =
  'click a.itemShow': 'itemShow'
  'click a.user': 'showUser'

module.exports = _.BasicPlugin events, handlers
