module.exports = Marionette.ItemView.extend
  tagName: 'li'
  className: 'browser-selector-li'
  template: require './templates/browser_selector_li'

  serializeData: ->
    attrs = @model.toJSON()
    return {
      # Adapting for entities, users, and groups
      label: attrs.label or attrs.username or attrs.name
      count: attrs.intersectionCount or attrs.count or attrs.itemsCount
      # Only entities will have an URI
      uri: attrs.uri
      # Only 'nearby'
      icon: attrs.icon
    }

  events:
    'click': 'select'

  select: -> @triggerMethod 'select', @model
