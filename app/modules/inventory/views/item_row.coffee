module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'item-row'
  template: require './templates/item_row'

  initialize: ->
    { @getSelectedIds, @isMainUser, @groupContext } = @options
    @listenTo @model, 'change', @lazyRender.bind(@)

    unless @model.userReady
      @model.waitForUser.then @lazyRender.bind(@)

  serializeData: ->
    _.extend @model.serializeData(),
      checked: @getCheckedStatus()
      isMainUser: @isMainUser
      groupContext: @groupContext

  events:
    'click .showItem': 'showItem'

  showItem: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:item', @model

  getCheckedStatus: ->
    if @getSelectedIds? then return @model.id in @getSelectedIds()
    else return false
