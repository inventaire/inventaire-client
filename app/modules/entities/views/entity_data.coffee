module.exports = Marionette.ItemView.extend
  template: require './templates/entity_data'
  className: 'entityPanel'
  initialize: (options)->
    @lazyRender = _.debounce @render.bind(@), 200
    @listenTo @model, 'change', @lazyRender

    @hidePicture = options.hidePicture
    unless @hidePicture
      @listenTo @model, 'add:pictures', @lazyRender

  serializeData: ->
    attrs = @model.toJSON()
    attrs = @setDescriptionAttributes(attrs)
    attrs.entityPage = @options.entityPage
    attrs.hidePicture = @hidePicture
    return attrs

  ui:
    description: '.description'
    togglers: '.toggler i'

  onRender: ->
    app.request('qLabel:update')

  events:
    'click .toggler': 'toggleDescLength'

  toggleDescLength: ->
    @ui.description.toggleClass 'clamped'
    @ui.togglers.toggleClass 'hidden'

  setDescriptionAttributes: (attrs)->
    if attrs.extract? then attrs.description = attrs.extract
    if attrs.description?
      attrs.descOverflow = attrs.description.length > 400

    return attrs
