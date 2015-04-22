module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/entity_data'
  className: 'entityPanel'
  serializeData: ->
    attrs = @model.toJSON()
    attrs = setDescriptionAttributes(attrs)
    return attrs

  initialize: ->
    @listenTo @model, 'add:pictures', @render

  onShow: ->
    app.request('qLabel:update')

  events:
    'click #toggleDescLength': 'toggleDescLength'

  toggleDescLength: ->
    $('#shortDesc').toggle()
    $('#fullDesc').toggle()
    $('#toggleDescLength').find('i').toggleClass('hidden')

setDescriptionAttributes = (attrs)->
  if attrs.description?
    attrs.descMaxlength = 500
    attrs.descOverflow = attrs.description.length > attrs.descMaxlength

  return attrs