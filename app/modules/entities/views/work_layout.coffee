WorkInfobox = require './work_infobox'
EditionsList = require './editions_list'
EntityActions = require './entity_actions'
entityItems = require '../lib/entity_items'
{ showHomonyms } = require('./author_layout').prototype

module.exports = Marionette.LayoutView.extend
  template: require './templates/work_layout'
  regions:
    workInfobox: '#workInfobox'
    editionsList: '#editionsList'
    # Prefix regions selectors with 'work' to avoid collisions with editions
    # displayed as sub-views
    entityActions: '.workEntityActions'
    personalItemsRegion: '.workPersonalItems'
    networkItemsRegion: '.workNetworkItems'
    publicItemsRegion: '.workPublicItems'
    homonymsRegion: '.homonyms'

  initialize: ->
    entityItems.initialize.call @
    { @item } = @options
    @displayHomonyms = app.user.isAdmin

  serializeData: ->
    _.extend @model.toJSON(),
      canRefreshData: true
      displayHomonyms: @displayHomonyms

  onShow: ->
    @showWorkInfobox()

    if @item? then @showItemModal @item
    else @completeShow()

  showItemModal: (item)->
    app.execute 'show:item:modal', item
    @listenToOnce app.vent, 'modal:closed', @onClosedItemModal.bind(@)

  completeShow: ->
    # Run only once
    if @_showWasCompleted then return
    @_showWasCompleted = true

    # Need to wait to know if the user has an instance of this work
    @waitForItems
    .then @ifViewIsIntact('showEntityActions')

    @model.waitForSubentities
    .then @ifViewIsIntact('showEditions')

  onRender: ->
    entityItems.onRender.call @
    if @displayHomonyms then showHomonyms.call @

  events:
    'click a.showWikipediaPreview': 'toggleWikipediaPreview'

  showWorkInfobox: ->
    @workInfobox.show new WorkInfobox { @model, standalone: true }

  showEntityActions: -> @entityActions.show new EntityActions { @model }

  showEditions: ->
    @editionsList.show new EditionsList
      collection: @model.editions
      work: @model
      onWorkLayout: true

  toggleWikipediaPreview: -> @$el.trigger 'toggleWikiIframe', @

  onClosedItemModal: ->
    @completeShow()
    app.navigateFromModel @model, null, { preventScrollTop: true }

  # Close the item modal when another view is shown in place of this layout
  onDestroy: -> app.execute 'modal:close'
