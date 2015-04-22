module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/entity_data'
  className: 'entityPanel'
  serializeData: ->
    attrs = @model.toJSON()
    attrs = setDescriptionAttributes(attrs)
    attrs.hidePicture = @hidePicture
    return attrs

  initialize: (options)->
    @hidePicture = options.hidePicture
    if @hidePicture
      @listenTo @model, 'add:pictures', @render

  onRender: ->
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