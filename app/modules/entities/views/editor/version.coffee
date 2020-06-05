module.exports = Marionette.ItemView.extend
  className: 'version'
  template: require './templates/version'
  initialize: ->

  serializeData: -> @model.serializeData()

  modelEvents:
    'grab': 'lazyRender'
