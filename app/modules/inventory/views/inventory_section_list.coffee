ListEl = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/inventory_section_list_li'

  initialize: ->
    { @context, @group } = @options

  serializeData: ->
    attrs = @model.serializeData()
    attrs.isGroup = attrs.type is 'group'
    attrs.isGroupAdmin = @isGroupAdmin()
    attrs.hasItemsCount = attrs.itemsCount?
    return attrs

  events:
    'click a': 'selectInventory'

  isGroupAdmin: -> @context is 'group' and @group.allAdminsIds().includes(@model.id)

  selectInventory: (e)->
    if _.isOpenedOutside e then return
    type = if @model.get('type') is 'group' then 'group' else 'user'
    if type is 'user' and @context is 'group' then type = 'member'
    app.vent.trigger 'inventory:select', type, @model
    e.preventDefault()

module.exports = Marionette.CollectionView.extend
  tagName: 'ul'
  childView: ListEl
  childViewOptions: ->
    context: @options.context
    group: @options.group
  emptyView: require 'modules/inventory/views/no_item'
  emptyViewOptions:
    showIcon: false
