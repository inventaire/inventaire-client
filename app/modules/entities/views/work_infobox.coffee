AuthorsPreviewList = require 'modules/entities/views/authors_preview_list'
clampedExtract = require '../lib/clamped_extract'

module.exports = Marionette.LayoutView.extend
  template: require './templates/work_infobox'
  className: 'workInfobox flex-column-center-center'
  regions:
    authors: '.authors'

  behaviors:
    PreventDefault: {}
    EntitiesCommons: {}
    ClampedExtract: {}

  initialize: (options)->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    @hidePicture = options.hidePicture
    @waitForAuthors = @model.getAuthorsModels()
    @model.getWikipediaExtract()

  serializeData: ->
    attrs = @model.toJSON()
    clampedExtract.setAttributes attrs
    attrs.standalone = @options.standalone
    attrs.hidePicture = @hidePicture
    setImagesSubGroups attrs
    return attrs

  onRender: ->
    app.execute 'uriLabel:update'

    @waitForAuthors
    .then @ifViewIsIntact('showAuthorsPreviewList')

  showAuthorsPreviewList: (authors)->
    if authors.length is 0 then return

    collection = new Backbone.Collection authors
    @authors.show new AuthorsPreviewList { collection }

setImagesSubGroups = (attrs)->
  { images } = attrs
  unless images? then return
  attrs.mainImage = images[0]
  attrs.secondaryImages = images.slice(1)
