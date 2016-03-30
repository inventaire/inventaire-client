module.exports = Marionette.ItemView.extend
  template: require './templates/previous_search'
  tagName: 'li'
  behaviors:
    PreventDefault: {}

  serializeData: -> @model.serializeData()

  events:
    'click a': 'showSearch'

  showSearch: -> app.execute 'search:global', @model.get('query')
