module.exports = Marionette.ItemView.extend
  template: require './templates/item_preview'
  className: 'item-preview'
  behaviors:
    PreventDefault: {}

  onShow: ->
    unless @model.user?
      @model.waitForUser
      .then @ifViewIsIntact('render')

  serializeData: ->
    transaction = @model.get 'transaction'
    _.extend @model.serializeData(),
      showDetails: @options.showDetails
      title: buildTitle @model.user, transaction

  events:
    'click .showItem': 'showItem'

  showItem: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item', @model


buildTitle = (user, transaction)->
  unless user? then return
  username = user.get 'username'
  title = _.i18n "#{transaction}_personalized", { username }
  if user.distanceFromMainUser?
    title += " (#{_.i18n('km_away', { distance: user.distanceFromMainUser })})"
  return title
