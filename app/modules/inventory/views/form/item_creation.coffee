EntityData = require 'modules/entities/views/entity_data'
scanner = require 'lib/scanner'
{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'

module.exports = Marionette.LayoutView.extend
  template: require './templates/item_creation'
  className: 'addEntity'
  regions:
    entityRegion: '#entity'
  behaviors:
    ElasticTextarea: {}
    ItemCreationSelect:
      behaviorClass: ItemCreationSelect

  ui:
    transaction: '#transaction'
    listing: '#listing'
    details: '#details'
    notes: '#notes'

  initialize: ->
    @entity = @options.entity
    @createItem()

  createItem: ->
    attrs =
      # copying the title for convinience
      # as it is used to display and find the item from search
      title: @entity.get 'title'
      entity: @entity.get 'uri'
      transaction: @guessTransaction()
      listing: @guessListing()

    if pictures = @entity.get 'pictures'
      attrs.pictures = pictures

    unless attrs.entity? and attrs.title?
      throw new Error 'missing uri or title at item creation from entity'

    @model = app.request 'item:create', attrs

  guessTransaction: ->
    transaction = @options.transaction or app.request('last:transaction:get')
    app.execute 'last:transaction:set', transaction
    return transaction

  guessListing: -> app.request 'last:listing:get'

  onShow: ->
    app.execute 'foundation:reload'
    @selectTransaction()
    @selectListing()
    @showEntityData()

  onDestroy: ->
    # waiting for the page to be closed to have the best guess
    # on the chosen listing and transaction mode
    listing = @model.get 'listing'
    transaction = @model.get 'transaction'
    app.execute 'track:item', 'create', listing, transaction

  selectTransaction: -> @selectButton 'transaction'
  selectListing: -> @selectButton 'listing'
  selectButton: (attr)->
    value = @model.get attr
    if value?
      $el = @ui[attr].find "a[id=#{value}]"
      if $el.length is 1
        @ui[attr].find('a').removeClass 'active'
        $el.addClass 'active'

  serializeData: ->
    title = @entity.get('title')
    attrs =
      title: title
      listings: listingsData()
      transactions: transactionsData()
      header: _.i18n 'add_item_text', {title: title}

    attrs = @setAddModeSpecificAttr attrs
    return attrs

  setAddModeSpecificAttr: (attrs)->
    # if mobile and last add mode is scan
    # set #validateAndAddNext href to the scanner.url
    if _.isMobile
      @_addMode = app.request 'last:add:mode:get'
      if @_addMode is 'scan' then attrs.scanner = scanner
    return attrs

  events:
    'click #transaction': 'updateTransaction'
    'click #listing': 'updateListing'
    'click #cancel': 'destroyItem'
    'click #validate': 'validateSimple'
    'click #validateAndAddNext': 'validateAndAddNext'

  showEntityData: ->
    @entityRegion.show new EntityData { model: @entity }

  # TODO: update the UI for update errors
  updateTransaction: ->
    transaction = getSelectorData @, 'transaction'
    app.execute 'last:transaction:set', transaction
    @updateItem { transaction: transaction }
    .catch _.Error('updateTransaction err')

  updateListing: ->
    listing = getSelectorData @, 'listing'
    app.execute 'last:listing:set', listing
    @updateItem { listing: listing }
    .catch _.Error('updateListing err')

  updateDetails: -> @updateTextAttribute 'details'
  updateNotes: -> @updateTextAttribute 'notes'
  updateTextAttribute: (attr)->
    _.log arguments, 'updateTextAttribute'
    val = @ui[attr].val()
    update = {}
    update[attr] = val
    @updateItem update
    .catch _.Error('updateTextAttribute err')

  validateSimple: ->
    @validateItem()
    .then -> app.execute 'show:inventory:main:user'
    .catch _.Error('validateSimple err')

  validateAndAddNext: ->
    @validateItem()
    .then @addNext.bind(@)
    .catch _.Error('validateAndAddNext err')

  addNext: ->
    # if addMode is scan, the scanner should have opened a new window
    app.execute 'show:add:layout'

  validateItem: ->
    @updateItem
      details: @ui.details.val()
      notes: @ui.notes.val()

  updateItem: (data)->
    app.request 'item:update',
      item: @model
      data: data

  destroyItem: ->
    @model.destroy()
    .then -> window.history.back()
    .catch _.Error('destroyItem err')
