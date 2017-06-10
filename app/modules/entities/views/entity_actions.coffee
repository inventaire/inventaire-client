module.exports = Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  behaviors:
    PreventDefault: {}

  initialize: ->
    @uri = @model.get 'uri'

  serializeData: ->
    { itemToUpdate } = @options
    return { itemToUpdate }

  events:
    'click .add': 'add'
    'click .updateItem': 'updateItem'

  add: -> app.execute 'show:item:creation:form', { entity: @model }
  updateItem: ->
    app.request 'item:update:entity',
      item: @options.itemToUpdate
      entity: @model
