WorkData = require './work_data'
EditionsList = require './editions_list'
EntityActions = require './entity_actions'
entityItems = require '../lib/entity_items'

module.exports = Marionette.LayoutView.extend
  template: require './templates/work_layout'
  regions:
    workData: '#workData'
    editionsList: '#editionsList'
    entityActions: '#entityActions'
    personalItemsRegion: '.personalItems'
    networkItemsRegion: '.networkItems'
    publicItemsRegion: '.publicItems'

  serializeData: ->
    _.extend @model.toJSON(),
      canRefreshData: true

  initialize: ->
    entityItems.initialize.call @
    app.execute 'metadata:update:needed'

  onShow: ->
    @showWorkData()

    # Need to wait to know if the user has an instance of this work
    @waitForItems.then @showEntityActions.bind(@)

    @model.waitForSubentities.then @showEditions.bind(@)

    @model.updateMetadata()
    .then app.Execute('metadata:update:done')

  onRender: -> entityItems.onRender.call @

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
    'click .refreshData': 'refreshData'

  showWorkData: ->
    @workData.show new WorkData
      model: @model
      workPage: true

  showEditions: ->
    if @model.editions.length > 0
      @editionsList.show new EditionsList
        collection: @model.editions

  showEntityActions: -> @entityActions.show new EntityActions { @model }

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

  refreshData: -> app.execute 'show:entity:refresh', @model
