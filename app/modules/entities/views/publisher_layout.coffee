PublisherInfobox = require './publisher_infobox'
EditionsList = require './editions_list'

module.exports = Marionette.LayoutView.extend
  id: 'publisherLayout'
  className: 'standalone'
  template: require './templates/publisher_layout'
  regions:
    infoboxRegion: '.publisherInfobox'
    editionsList: '#editionsList'
    mergeSuggestionsRegion: '.mergeSuggestions'

  initialize: ->
    { @refresh, @standalone, @displayMergeSuggestions } = @options

  onShow: ->
    unless @standalone? then return

    @model.fetchSubEntities @refresh
    .then @ifViewIsIntact('showEditions')

  onRender: ->
    @showInfobox()
    if @displayMergeSuggestions then @showMergeSuggestions()

  serializeData: ->
    displayMergeSuggestions: @displayMergeSuggestions

  showInfobox: ->
    @infoboxRegion.show new PublisherInfobox { @model, @standalone }

  showEditions: ->
    @editionsList.show new EditionsList { collection: @model.editions }

  showMergeSuggestions: ->
    app.execute 'show:merge:suggestions', { @model, region: @mergeSuggestionsRegion }
