module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/entity_data'
  className: 'entityPanel'
  serializeData: ->
    attrs = @model.toJSON()
    attrs = setDescriptionAttributes(attrs)
    attrs.entityPage = @options.entityPage
    attrs.hidePicture = @hidePicture
    return attrs

  initialize: (options)->
    @lazyRender = _.debounce @render.bind(@), 200
    @listenTo @model, 'change', @lazyRender

    @hidePicture = options.hidePicture
    unless @hidePicture
      @listenTo @model, 'add:pictures', @lazyRender

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