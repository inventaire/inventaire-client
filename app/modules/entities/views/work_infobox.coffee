showAllAuthorsPreviewLists = require 'modules/entities/lib/show_all_authors_preview_lists'
clampedExtract = require '../lib/clamped_extract'

module.exports = Marionette.LayoutView.extend
  template: require './templates/work_infobox'
  className: 'workInfobox flex-column-center-center'
  regions:
    authors: '.authors'
    scenarists: '.scenarists'
    illustrators: '.illustrators'
    colorists: '.colorists'

  behaviors:
    PreventDefault: {}
    EntitiesCommons: {}
    ClampedExtract: {}

  initialize: (options)->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender
    @hidePicture = options.hidePicture
    @waitForAuthors = @model.getExtendedAuthorsModels()
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
    .then @ifViewIsIntact(showAllAuthorsPreviewLists)

setImagesSubGroups = (attrs)->
  { images } = attrs
  unless images? then return
  attrs.mainImage = images[0]
  attrs.secondaryImages = images.slice(1)
