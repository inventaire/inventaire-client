module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'browser-selector-li'
  template: require './templates/browser_selector_li'
  serializeData: ->
    # Adapting for entities, users, and groups
    label: @model.get('label') or @model.get('username') or @model.get('name')
    count: @model.get('count') or @model.get('itemsCount')
    # Only entities will have an URI
    uri: @model.get 'uri'
    # Only 'nearby'
    icon: @model.get 'icon'

  events:
    'click': 'select'

  select: -> @triggerMethod 'select', @model
