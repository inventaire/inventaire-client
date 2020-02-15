TypedEntityLayout = require './typed_entity_layout'
EditionsList = require './editions_list'
EntityActions = require './entity_actions'
entityItems = require '../lib/entity_items'

module.exports = TypedEntityLayout.extend
  id: 'workLayout'
  Infobox: require './work_infobox'
  template: require './templates/work_layout'
  regions:
    infoboxRegion: '#workInfobox'
    editionsList: '#editionsList'
    # Prefix regions selectors with 'work' to avoid collisions with editions
    # displayed as sub-views
    entityActions: '.workEntityActions'
    personalItemsRegion: '.workPersonalItems'
    networkItemsRegion: '.workNetworkItems'
    publicItemsRegion: '.workPublicItems'
    mergeSuggestionsRegion: '.mergeSuggestions'

  initialize: ->
    TypedEntityLayout::initialize.call @
    entityItems.initialize.call @
    @displayMergeSuggestions = app.user.isAdmin

  onRender: ->
    TypedEntityLayout::onRender.call @
    @lazyShowItems()

  serializeData: ->
    _.extend @model.toJSON(),
      displayMergeSuggestions: @displayMergeSuggestions

  onShow: ->
    # Need to wait to know if the user has an instance of this work
    @waitForItems
    .then @ifViewIsIntact('showEntityActions')

    @model.fetchSubEntities()
    .then @ifViewIsIntact('showEditions')

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'

  showEntityActions: -> @entityActions.show new EntityActions { @model }

  showEditions: ->
    @editionsList.show new EditionsList
      collection: @model.editions
      work: @model
      onWorkLayout: true

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

  showMergeSuggestions: ->
    app.execute 'show:merge:suggestions', { @model, region: @mergeSuggestionsRegion }
