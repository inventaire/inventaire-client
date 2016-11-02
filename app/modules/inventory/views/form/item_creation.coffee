WorkData = require 'modules/entities/views/work_data'
zxing = require 'modules/inventory/lib/scanner/zxing'
{ listingsData, transactionsData, getSelectorData } = require 'modules/inventory/lib/item_creation'
ItemCreationSelect = require 'modules/inventory/behaviors/item_creation_select'
error_ = require 'lib/error'

module.exports = Marionette.LayoutView.extend
  template: require './templates/item_creation'
  className: 'addWork'
  regions:
    workRegion: '#work'
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
    { @work } = @options
    @createItem()
    @_lastAddMode = app.request 'last:add:mode:get'

  createItem: ->
    attrs =
      # copying the title for convinience
      # as it is used to display and find the item from search
      title: @work.get 'label'
      entity: @work.get 'uri'
      transaction: @guessTransaction()
      listing: @guessListing()

    if pictures = @work.get 'images.url'
      attrs.pictures = pictures

    unless attrs.work? and attrs.title?
      throw error_.new 'missing uri or title at item creation from work', attrs

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
    @showWorkData()

  onDestroy: ->
    # waiting for the page to be closed to have the best guess
    # on the chosen listing and transaction mode
    listing = @model.get 'listing'
    transaction = @model.get 'transaction'

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
    title = @work.get 'label'
    attrs =
      title: title
      listings: listingsData()
      transactions: transactionsData()
      header: _.i18n 'add_item_text', { title }

    return _.extend attrs, @addNextData()

  addNextData: ->
    data = {}
    if @_lastAddMode is 'scan:zxing' then data.zxing = zxing
    return data

  events:
    'click #transaction': 'updateTransaction'
    'click #listing': 'updateListing'
    'click #cancel': 'destroyItem'
    'click #validate': 'validateSimple'
    'click #validateAndAddNext': 'validateAndAddNext'

  showWorkData: ->
    @workRegion.show new WorkData { model: @work }

  # TODO: update the UI for update errors
  updateTransaction: ->
    transaction = getSelectorData @, 'transaction'
    app.execute 'last:transaction:set', transaction
    @updateItem { transaction }
    .catch _.Error('updateTransaction err')

  updateListing: ->
    listing = getSelectorData @, 'listing'
    app.execute 'last:listing:set', listing
    @updateItem { listing }
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
    switch @_lastAddMode
      when 'search' then app.execute 'show:add:layout:search:last'
      when 'scan:embedded' then app.execute 'show:scanner:embedded'
      # If _lastAddMode is scan:zxing, the scanner should have been opened
      # by the click on the <a href=zxing.url>, which should open a new window
      # 'scan' is here as legacy
      when 'scan', 'scan:zxing' then return
      else
        _.warn @_lastAddMode, 'unknown or obsolete add mode'
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
    _.log 'item creation cancelled: destroying item'
    @model.destroy()
    .then _.Log('item destroyed')
    .then -> window.history.back()
    .catch _.Error('destroyItem err')
