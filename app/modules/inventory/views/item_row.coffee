module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'item-row'
  template: require './templates/item_row'

  initialize: ->
    { @isMainUser } = @options
    @listenTo @model, 'change', @render.bind(@)

  serializeData: ->
    _.extend @model.serializeData(),
      checked: @getCheckedStatus()
      isMainUser: @isMainUser

  events:
    'click .showItem': 'showItem'

  showItem: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:item', @model

  getCheckedStatus: -> @model.id in @options.getSelectedIds?()
