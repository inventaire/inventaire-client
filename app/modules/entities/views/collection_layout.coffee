TypedEntityLayout = require './typed_entity_layout'
EditionsList = require './editions_list'
GeneralInfobox = require './general_infobox'

Infobox = GeneralInfobox.extend
  template: require './templates/collection_infobox.hbs'

module.exports = TypedEntityLayout.extend
  id: 'collectionLayout'
  className: 'standalone'
  template: require './templates/collection_layout'
  Infobox: Infobox
  regions:
    infoboxRegion: '.collectionInfobox'
    editionsList: '#editionsList'
    mergeSuggestionsRegion: '.mergeSuggestions'

  onShow: ->
    unless @standalone? then return

    @model.fetchSubEntities @refresh
    .then @ifViewIsIntact('showEditions')

  showEditions: ->
    @editionsList.show new EditionsList { collection: @model.editions, sortByLang: false }
