plainTextAuthorLink = require '../plugins/plain_text_author_link'

module.exports = Marionette.ItemView.extend
  template: require './templates/entity_data'
  className: 'entityData'
  initialize: (options)->
    @initPlugin()
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender

    @hidePicture = options.hidePicture
    unless @hidePicture
      @listenTo @model, 'add:pictures', @lazyRender

  initPlugin: ->
    plainTextAuthorLink.call @

  serializeData: ->
    attrs = @model.toJSON()
    attrs = @setDescriptionAttributes(attrs)
    attrs.entityPage = @options.entityPage
    attrs.hidePicture = @hidePicture
    return attrs

  ui:
    description: '.description'
    togglers: '.toggler i'

  behaviors:
    PreventDefault: {}

  onRender: ->
    app.request 'qLabel:update'

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
