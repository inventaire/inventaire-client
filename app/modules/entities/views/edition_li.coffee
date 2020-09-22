entityItems = require '../lib/entity_items'
EntityActions = require './entity_actions'

module.exports = Marionette.LayoutView.extend
  template: require './templates/edition_li'
  tagName: 'li'
  className: 'edition-commons editionLi'
  regions:
    # Prefix regions selectors with 'edition' to avoid collisions with
    # the work own regions
    personalItemsRegion: '.editionPersonalItems'
    networkItemsRegion: '.editionNetworkItems'
    publicItemsRegion: '.editionPublicItems'
    nearbyPublicItemsRegion: '.editionNearbyPublicItems'
    otherPublicItemsRegion: '.editionOtherPublicItems'
    entityActions: '.editionEntityActions'

  initialize: ->
    { @itemToUpdate, @compactMode, @onWorkLayout } = @options
    unless @itemToUpdate? or @compactMode then entityItems.initialize.call @

  onRender: ->
    unless @itemToUpdate? or @compactMode then @lazyShowItems()
    @showEntityActions()

  serializeData: ->
    _.extend @model.toJSON(),
      itemUpdateContext: @itemToUpdate?
      onWorkLayout: @onWorkLayout
      compactMode: @compactMode
      itemsListsDisabled: @itemToUpdate or @compactMode

  showEntityActions: ->
    if @compactMode then return
    @entityActions.show new EntityActions { @model, @itemToUpdate }
