showAllAuthorsPreviewLists = require 'modules/entities/lib/show_all_authors_preview_lists'
clampedExtract = require '../lib/clamped_extract'

module.exports = Marionette.LayoutView.extend
  template: require './templates/serie_infobox'
  behaviors:
    EntitiesCommons: {}
    ClampedExtract: {}

  regions:
    authors: '.authors'
    scenarists: '.scenarists'
    illustrators: '.illustrators'
    colorists: '.colorists'

  initialize: ->
    @waitForAuthors = @model.getExtendedAuthorsModels()
    @model.getWikipediaExtract()

  modelEvents:
    # The description might be overriden by a Wikipedia extract arrive later
    'change:description': 'render'

  serializeData: ->
    attrs = @model.toJSON()
    clampedExtract.setAttributes attrs
    attrs.standalone = @options.standalone
    attrs.showCleanupButton = app.user.hasDataadminAccess
    return attrs

  onRender: ->
    @waitForAuthors
    .then @ifViewIsIntact(showAllAuthorsPreviewLists)
