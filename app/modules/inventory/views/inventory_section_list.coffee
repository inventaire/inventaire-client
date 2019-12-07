ListEl = Marionette.ItemView.extend
  tagName: 'li'
  template: require './templates/inventory_section_list_li'

  initialize: ->
    { @context } = @options

  serializeData: ->
    attrs = @model.serializeData()
    attrs.isGroup = attrs.type is 'group'
    return attrs

  events:
    'click a': 'selectInventory'

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
