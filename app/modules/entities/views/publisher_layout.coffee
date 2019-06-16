TypedEntityLayout = require './typed_entity_layout'
EditionsList = require './editions_list'

module.exports = TypedEntityLayout.extend
  id: 'publisherLayout'
  className: 'standalone'
  template: require './templates/publisher_layout'
  Infobox: require './publisher_infobox'
  regions:
    infoboxRegion: '.publisherInfobox'
    editionsList: '#editionsList'
    mergeSuggestionsRegion: '.mergeSuggestions'

  onShow: ->
    unless @standalone? then return

    @model.fetchSubEntities @refresh
    .then @ifViewIsIntact('showEditions')

  showEditions: ->
    @editionsList.show new EditionsList { collection: @model.editions }
