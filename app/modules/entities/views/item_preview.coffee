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
    _.extend @model.serializeData(),
      showDetails: @options.showDetails

  events:
    'click .showItem': 'showItem'

  showItem: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:item:show:from:model', @model
