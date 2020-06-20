module.exports = Marionette.ItemView.extend
  className: 'entities-list-element-candidate'
  template: require './templates/entities_list_element_candidate'
  events:
    'click .add': 'add'

  add: ->
    { parentModel, listCollection } = @options

    listCollection.add @model

    { childrenClaimProperty } = parentModel
    uri = parentModel.get('uri')

    @updateStatus()

    @model.setPropertyValue childrenClaimProperty, null, uri
    .then -> app.execute 'invalidate:entities:graph', uri

  updateStatus: ->
    # Use classes instead of a re-render to prevent blinking {{claim}} labels
    @$el.find('.add').addClass 'hidden'
    @$el.find('.added').removeClass 'hidden'
