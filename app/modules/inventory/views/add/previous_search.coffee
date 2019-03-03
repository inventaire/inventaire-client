module.exports = Marionette.ItemView.extend
  template: require './templates/previous_search'
  tagName: 'li'
  className: 'previous-search'
  behaviors:
    PreventDefault: {}

  serializeData: -> @model.serializeData()

  events:
    'click a': 'showSearch'

  showSearch: -> @model.show()
