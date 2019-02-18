module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'item-row'
  template: require './templates/item_row'

  initialize: ->
    @listenTo @model, 'change', @render.bind(@)

  serializeData: ->
    _.extend @model.serializeData(),
      checked: @checked

  events:
    'click .showItem': 'showItem'
    'change input[name="select"]': 'select'

  showItem: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:item', @model

  select: (e)->
    { @checked } = e.currentTarget
