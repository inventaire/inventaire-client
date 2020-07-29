entityItems = require '../lib/entity_items'
EntityActions = require './entity_actions'

module.exports = Marionette.LayoutView.extend
  template: require './templates/edition_layout'
  className: 'edition-commons editionLayout standalone'
  regions:
    # Prefix regions selectors with 'edition' to avoid collisions with
    # the work own regions
    personalItemsRegion: '.editionPersonalItems'
    networkItemsRegion: '.editionNetworkItems'
    publicItemsRegion: '.editionPublicItems'
    nearbyPublicItemsRegion: '.editionNearbyPublicItems'
    otherPublicItemsRegion: '.editionOtherPublicItems'
    entityActions: '.editionEntityActions'
    works: '.works'

  initialize: ->
    @standalone = true
    @displayItemsCovers = false
    entityItems.initialize.call @

  onShow: ->
    @model.waitForWorks
    .map (work)-> work.fetchSubEntities()
    .then @ifViewIsIntact('showWorks')

  showWorks: ->
    collection = new Backbone.Collection @model.works
    @works.show new EditionWorks { collection }

  onRender: ->
    @lazyShowItems()
    @showEntityActions()

  serializeData: ->
    _.extend @model.toJSON(),
      standalone: @standalone
      onWorkLayout: @options.onWorkLayout
      works: @model.works?.map (work)-> work.toJSON()

  showEntityActions: ->
    { itemToUpdate } = @options
    @entityActions.show new EntityActions { @model, itemToUpdate }

EditionWork = Marionette.ItemView.extend
  className: 'edition-work'
  template: require './templates/edition_work'

EditionWorks = Marionette.CollectionView.extend
  className: 'edition-works'
  childView: EditionWork
