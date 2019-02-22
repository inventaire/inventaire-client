PublisherInfobox = require './publisher_infobox'
EditionsList = require './editions_list'
entityItems = require '../lib/entity_items'

module.exports = Marionette.LayoutView.extend
  className: 'publisherLayout'
  template: require './templates/publisher_layout'
  regions:
    infoboxRegion: '.publisherInfobox'
    editionsList: '#editionsList'

  initialize: ->
    entityItems.initialize.call @
    { @item } = @options
    @displayMergeSuggestions = app.user.isAdmin

  serializeData: ->
    _.extend @model.toJSON(),
      canRefreshData: true

  onShow: ->
    # Run only once
    if @_showWasCompleted then return
    @_showWasCompleted = true

    @model.waitForSubentities
    .then @ifViewIsIntact('showEditions')

  onRender: ->
    @showInfobox()

  showInfobox: ->
    @infoboxRegion.show new PublisherInfobox { @model, @standalone }

  showEditions: ->
    @editionsList.show new EditionsList
      collection: @model.editions
