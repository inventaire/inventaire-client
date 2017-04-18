AuthorsPreviewList = require 'modules/entities/views/authors_preview_list'

module.exports = Marionette.LayoutView.extend
  template: require './templates/work_data'
  className: 'workData flex-column-center-center'
  regions:
    authors: '.authors'

  ui:
    description: '.description'
    togglers: '.toggler i'

  behaviors:
    PreventDefault: {}

  initialize: (options)->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    @hidePicture = options.hidePicture
    @waitForAuthors = @model.getAuthorsModels()

  serializeData: ->
    attrs = @model.toJSON()
    attrs = @setDescriptionAttributes(attrs)
    attrs.workPage = @options.workPage
    attrs.hidePicture = @hidePicture
    return attrs

  onRender: ->
    app.execute 'uriLabel:update'

    @waitForAuthors.then @showAuthorsPreviewList.bind(@)

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

  showAuthorsPreviewList: (authors)->
    if authors.length is 0 then return

    collection = new Backbone.Collection authors
    @authors.show new AuthorsPreviewList { collection }
