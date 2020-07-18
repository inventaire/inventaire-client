module.exports = Marionette.ItemView.extend
  template: require './templates/item_preview'
  className: 'item-preview'
  behaviors:
    PreventDefault: {}

  onShow: ->
    unless @model.user? then @model.waitForUser.then @lazyRender.bind(@)

  serializeData: ->
    transaction = @model.get 'transaction'
    _.extend @model.serializeData(),
      title: buildTitle @model.user, transaction
      distanceFromMainUser: @model.user.distanceFromMainUser

  events:
    'click .showItem': 'showItem'

  showItem: (e)->
    if _.isOpenedOutside e then return
    app.execute 'show:item', @model

buildTitle = (user, transaction)->
  unless user? then return
  username = user.get 'username'
  title = _.i18n "#{transaction}_personalized", { username }
  if user.distanceFromMainUser?
    title += " (#{_.i18n('km_away', { distance: user.distanceFromMainUser })})"
  return title
