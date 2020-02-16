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
    entityActions: '.editionEntityActions'

  initialize: ->
    { @itemToUpdate } = @options
    unless @itemToUpdate? then entityItems.initialize.call @

  onRender: ->
    unless @itemToUpdate? then @lazyShowItems()
    @showEntityActions()

  serializeData: ->
    _.extend @model.toJSON(),
      itemUpdateContext: @itemToUpdate?
      onWorkLayout: @options.onWorkLayout

  showEntityActions: ->
    @entityActions.show new EntityActions { @model, @itemToUpdate }
