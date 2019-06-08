entityItems = require '../lib/entity_items'
EntityActions = require './entity_actions'

module.exports = Marionette.LayoutView.extend
  getTemplate: ->
    if @options.standalone then require './templates/edition_layout'
    else require './templates/edition_li'
  tagName: -> if @options.standalone then 'div' else 'li'
  className: ->
    className = 'edition-commons'
    className += if @options.standalone then ' editionLayout standalone' else ' editionLi'
    return className

  regions:
    # Prefix regions selectors with 'edition' to avoid collisions with
    # the work own regions
    personalItemsRegion: '.editionPersonalItems'
    networkItemsRegion: '.editionNetworkItems'
    publicItemsRegion: '.editionPublicItems'
    entityActions: '.editionEntityActions'
    works: '.works'

  initialize: ->
    entityItems.initialize.call @
    { @standalone } = @options

  onShow: ->
    unless @standalone then return

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
      works: if @standalone then @model.works?.map (work)-> work.toJSON()

  showEntityActions: ->
    { itemToUpdate } = @options
    @entityActions.show new EntityActions { @model, itemToUpdate }

EditionWork = Marionette.ItemView.extend
  className: 'edition-work'
  template: require './templates/edition_work'

EditionWorks = Marionette.CollectionView.extend
  className: 'edition-works'
  childView: EditionWork
