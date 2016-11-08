module.exports = Marionette.ItemView.extend
  template: require './templates/work_data'
  className: 'workData flex-column-center-center'
  initialize: (options)->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    @hidePicture = options.hidePicture

  serializeData: ->
    attrs = @model.toJSON()
    attrs = @setDescriptionAttributes(attrs)
    attrs.workPage = @options.workPage
    attrs.hidePicture = @hidePicture
    return attrs

  ui:
    description: '.description'
    togglers: '.toggler i'

  behaviors:
    PreventDefault: {}
    PlainTextAuthorLink: {}

  onRender: ->
    app.execute 'uriLabel:update'

  events:
    'click .toggler': 'toggleDescLength'

  toggleDescLength: ->
    @ui.description.toggleClass 'clamped'
    @ui.togglers.toggleClass 'hidden'

  setDescriptionAttributes: (attrs)->
    if attrs.extract? then attrs.description = attrs.extract
    if attrs.description?
      attrs.descOverflow = attrs.description.length > 600

    return attrs
