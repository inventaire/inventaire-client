TypedEntityLayout = require './typed_entity_layout'
EntitiesList = require './entities_list'
GeneralInfobox = require './general_infobox'
PaginatedEntities = require 'modules/entities/collections/paginated_entities'

Infobox = GeneralInfobox.extend
  template: require './templates/collection_infobox.hbs'

module.exports = TypedEntityLayout.extend
  baseClassName: 'collectionLayout'
  template: require './templates/collection_layout'
  Infobox: Infobox
  regions:
    infoboxRegion: '.collectionInfobox'
    editionsList: '#editionsList'
    mergeSuggestionsRegion: '.mergeSuggestions'

  onShow: ->
    @model.fetchSubEntitiesUris @refresh
    .then @ifViewIsIntact('showPaginatedEditions')

  serializeData: ->
    standalone: @standalone

  showPaginatedEditions: (uris)->
    collection = new PaginatedEntities null, { uris, defaultType: 'edition' }
    @editionsList.show new EntitiesList
      collection: collection
      hideHeader: not @standalone
      compactMode: true
      parentModel: @model
      type: 'edition'
      title: 'editions'
