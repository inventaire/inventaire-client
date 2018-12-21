AuthorsPreviewList = require 'modules/entities/views/authors_preview_list'
clampedExtract = require '../lib/clamped_extract'

module.exports = Marionette.LayoutView.extend
  template: require './templates/serie_infobox'
  behaviors:
    EntitiesCommons: {}
    ClampedExtract: {}

  regions:
    authors: '.authors'

  initialize: ->
    @waitForAuthors = @model.getAuthorsModels()
    @model.getWikipediaExtract()

  modelEvents:
    # The description might be overriden by a Wikipedia extract arrive later
    'change:description': 'render'

  serializeData: ->
    attrs = @model.toJSON()
    clampedExtract.setAttributes attrs
    attrs.standalone = @options.standalone
    attrs.showCleanupButton = app.user.isAdmin
    return attrs

  onRender: ->
    @waitForAuthors
    .then @ifViewIsIntact('showAuthorsPreviewList')

  showAuthorsPreviewList: (authors)->
    if authors.length is 0 then return

    collection = new Backbone.Collection authors
    @authors.show new AuthorsPreviewList { collection }
