itemActions = require '../plugins/item_actions'

module.exports = Marionette.ItemView.extend
  tagName: 'tr'
  template: require './templates/item_row'
  behaviors:
    PreventDefault: {}

  initialize: ->
    console.log 'lol'
    @initPlugins()

  initPlugins: ->
    itemActions.call(@)

  serializeData: ->
    attrs = @model.serializeData()
    _.extend attrs,
      entityData: @model.entityModel?.toJSON()
    return _.log attrs

  onRender: ->
    app.request 'qLabel:update'
