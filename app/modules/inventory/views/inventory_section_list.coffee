ListEl = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/inventory_section_list_li'

  initialize: ->
    { @context, @group } = @options
    if @model.get('hasItemsCount')
      @model.waitForItemsCount.then @lazyRender.bind(@)

  serializeData: ->
    attrs = @model.serializeData()
    attrs.isGroup = attrs.type is 'group'
    attrs.isGroupAdmin = @isGroupAdmin()
    return attrs

  onShow: ->
    @listenTo app.vent,
      'refresh:shelves:items': @refreshItemsCount

  events:
    'click a': 'selectInventory'

  isGroupAdmin: -> @context is 'group' and @model.id in @group.allAdminsIds()

  refreshItemsCount: (shelfId, itemsCount)->
    if @model.get('_id') is shelfId
      @model.set 'itemsCount', itemsCount
      @lazyRender()

  selectInventory: (e)->
    if _.isOpenedOutside e then return
    type = @model.get('type') or 'user'
    if type is 'user' and @context is 'group' then type = 'member'
    app.vent.trigger 'inventory:select', type, @model
    e.preventDefault()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ListEl
  childViewOptions: ->
    context: @options.context
    group: @options.group
