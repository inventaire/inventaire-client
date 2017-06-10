module.exports = Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  behaviors:
    PreventDefault: {}

  initialize: ->
    @uri = @model.get 'uri'

  events:
    'click .add': 'add'

  add: -> app.execute 'show:item:creation:form', { entity: @model }
