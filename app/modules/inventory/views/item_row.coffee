itemActions = require '../plugins/item_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'tr'
  template: require './templates/item_row'
  behaviors:
    PreventDefault: {}
    PlainTextAuthorLink: {}

  initialize: ->
    @initPlugins()

  initPlugins: ->
    itemActions.call @

  serializeData: -> @model.serializeData()

  onRender: ->
    app.execute 'qlabel:update'
