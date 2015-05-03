itemActions = require '../plugins/item_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'tr'
  template: require './templates/item_row'
  behaviors:
    PreventDefault: {}

  initialize: ->
    @initPlugins()

  initPlugins: ->
    itemActions.call(@)

  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      entityData: @model.entityModel?.toJSON()
    return attrs

  onRender: ->
    app.request 'qLabel:update'
