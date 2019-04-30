PublisherInfobox = require './publisher_infobox'
EditionsList = require './editions_list'

module.exports = Marionette.LayoutView.extend
  className: 'publisherLayout standalone'
  template: require './templates/publisher_layout'
  regions:
    infoboxRegion: '.publisherInfobox'
    editionsList: '#editionsList'

  initialize: ->
    @displayMergeSuggestions = app.user.isAdmin

  onShow: ->
    @model.waitForSubentities
    .then @ifViewIsIntact('showEditions')

  onRender: ->
    @showInfobox()

  showInfobox: ->
    @infoboxRegion.show new PublisherInfobox { @model, @standalone }

  showEditions: ->
    @editionsList.show new EditionsList { collection: @model.editions }
