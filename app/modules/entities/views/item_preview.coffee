module.exports = Marionette.ItemView.extend
  template: require './templates/item_preview'
  className: 'item-preview'
  behaviors:
    PreventDefault: {}

  onShow: ->
    unless @model.user?
      @model.waitForUser
      .then @render.bind(@)

  serializeData: ->
    transaction = @model.get 'transaction'
    username = @model.user.get 'username'
    _.extend @model.serializeData(),
      showDetails: @options.showDetails
      title: _.i18n "#{transaction}_personalized", { username }

  events:
    'click .showItem': 'showItem'

  showItem: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item:show:from:model', @model
