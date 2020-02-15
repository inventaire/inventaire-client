module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'item-row'
  template: require './templates/item_row'

  initialize: ->
    { @isMainUser, @getSelectedIds } = @options
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

  getCheckedStatus: ->
    if @getSelectedIds? then return @model.id in @getSelectedIds()
    else return false
