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

  initialize: ->
    entityItems.initialize.call @
    { @item } = @options

  serializeData: ->
    _.extend @model.toJSON(),
      canRefreshData: true

  onShow: ->
    @showWorkData()

    if @item? then @showItemModal @item
    else @completeShow()

  showItemModal: (item)->
    item.work or= @model
    app.execute 'show:item:modal', item
    @listenToOnce app.vent, 'modal:closed', @onClosedItemModal.bind(@)

  completeShow: ->
    # Need to wait to know if the user has an instance of this work
    @waitForItems.then @showEntityActions.bind(@)

    @model.waitForSubentities
    # Let the time to the collection to the edition collection to initialize,
    # otherwise it seems to mess with the filter/render process
    .delay 10
    .then @showEditions.bind(@)

  onRender: -> entityItems.onRender.call @

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'
    'click .refreshData': 'refreshData'

  showWorkData: ->
    @workData.show new WorkData { @model, workPage: true }

  showEntityActions: ->
    @entityActions.show new EntityActions { @model, onAdd: @onAdd.bind(@) }

  onAdd: ->
    app.layout.modal.show new EditionsList
      collection: @model.editions
      work: @model
      header: 'select an edition'
    app.execute 'modal:open', 'large'

  showEditions: ->
    @editionsList.show new EditionsList
      collection: @model.editions
      work: @model

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

  refreshData: -> app.execute 'show:entity:refresh', @model

  onClosedItemModal: ->
    @completeShow()
    app.navigateFromModel @model

  # Close the item modal when another view is shown in place of this layout
  onDestroy: -> app.execute 'modal:close'
