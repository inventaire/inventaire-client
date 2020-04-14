EntityDataOverview = require 'modules/entities/views/entity_data_overview'
NewItemShelves = require '../new_item_shelves'
{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
{ getShelvesByOwner } = require 'modules/shelves/lib/shelf'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'
forms_ = require 'modules/general/lib/forms'
error_ = require 'lib/error'

ItemsList = Marionette.CollectionView.extend
  childView: require 'modules/inventory/views/item_row'

module.exports = Marionette.LayoutView.extend
  template: require './templates/item_creation'
  className: 'addEntity'

  regions:
    existingEntityItemsRegion: '#existingEntityItems'
    entityRegion: '#entity'
    shelves: '#shelves'

  behaviors:
    ElasticTextarea: {}
    ItemCreationSelect:
      behaviorClass: ItemCreationSelect
    AlertBox: {}

  ui:
    transaction: '#transaction'
    listing: '#listing'
    details: '#details'
    notes: '#notes'

  initialize: ->
    { @entity, @existingEntityItems } = @options
    @initItemData()
    @_lastAddMode = app.request 'last:add:mode:get'

    @waitForExistingInstances = app.request 'item:main:user:entity:items', @entity.get('uri')

  initItemData: ->
    { entity, transaction } = @options

    @itemData =
      entity: entity.get 'uri'
      transaction: guessTransaction transaction
      listing: app.request 'last:listing:get'

    # We need to specify a lang for work entities
    if entity.type is 'work' then @itemData.lang = guessLang entity

    unless @itemData.entity? then throw error_.new 'missing uri', @itemData

  serializeData: ->
    title = @entity.get 'label'

    attrs =
      title: title
      listings: listingsData @itemData.listing
      transactions: transactionsData @itemData.transaction
      header: _.i18n 'add_item_text', { title }

    return attrs

  onShow: ->
    @showEntityData()
    @showExistingInstances()
    @showShelves()

  events:
    'click #transaction': 'updateTransaction'
    'click #listing': 'updateListing'
    'click #cancel': 'cancel'
    'click #validate': 'validateSimple'
    'click #validateAndAddNext': 'validateAndAddNext'

  showEntityData: ->
    @entityRegion.show new EntityDataOverview { model: @entity }

  showExistingInstances: ->
    @waitForExistingInstances
    .then (existingEntityItems)=>
      if existingEntityItems.length is 0 then return
      collection = new Backbone.Collection existingEntityItems
      @$el.find('#existingEntityItemsWarning').show()
      @existingEntityItemsRegion.show new ItemsList { collection }

  showShelves: ->
    getShelvesByOwner()
    .then (shelves) => @shelvesCollection = new Backbone.Collection shelves
    .then @ifViewIsIntact('_showShelves')

  _showShelves: ->
    @shelves.show new NewItemShelves { collection: @shelvesCollection, item: @itemData }

  # TODO: update the UI for update errors
  updateTransaction: ->
    transaction = getSelectorData @, 'transaction'
    @itemData.transaction = transaction

  updateListing: ->
    listing = getSelectorData @, 'listing'
    @itemData.listing = listing

  validateSimple: ->
    @createItem()
    .then -> app.execute 'show:inventory:main:user'

  validateAndAddNext: ->
    @createItem()
    .then @addNext.bind(@)

  createItem: ->
    # the value of 'transaction' and 'listing' were updated on selectors clicks
    @itemData.details = @ui.details.val()
    @itemData.notes = @ui.notes.val()

    app.request 'item:create', @itemData
    .catch error_.Complete('.panel')
    .catch forms_.catchAlert.bind(null, @)

  addNext: ->
    switch @_lastAddMode
      when 'search' then app.execute 'show:add:layout:search'
      when 'scan:embedded' then app.execute 'show:scanner:embedded'
      else
        # Known case: 'scan:zxing'
        _.warn @_lastAddMode, 'unknown or obsolete add mode'
        app.execute 'show:add:layout'

  cancel: ->
    if Backbone.history.last.length > 0 then window.history.back()
    else app.execute 'show:home'

guessTransaction = (transaction)->
  transaction = transaction or app.request('last:transaction:get')
  if transaction is 'null' then transaction = null
  app.execute 'last:transaction:set', transaction
  return transaction

guessLang = (entity)->
  { lang:userLang } = app.user
  [ labels, originalLang ] = entity.gets 'labels', 'originalLang'
  if labels[userLang]? then return userLang
  if labels[originalLang]? then return originalLang
  if labels.en? then return 'en'
  # If none of the above worked, return the first lang we find
  return Object.keys(labels)[0]
