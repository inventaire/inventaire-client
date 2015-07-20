EntityData = require 'modules/entities/views/entity_data'
scanner = require 'lib/scanner'

module.exports = Marionette.LayoutView.extend
  template: require './templates/item_creation'
  className: 'addEntity'
  regions:
    entityRegion: '#entity'
  behaviors:
    ElasticTextarea: {}

  ui:
    'transaction': '#transaction'
    'listing': '#listing'
    'details': '#details'
    'notes': '#notes'

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

    # will be confirmed by the server
    attrs.owner = app.user.id
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
      listings: @listingsData()
      transactions: @transactionsData()
      header: _.i18n 'add_item_text', {title: title}

    attrs = @setAddModeSpecificAttr attrs
    return attrs

  listingsData: ->
    listings = _.clone(app.user.listings)
    listings.private.classes = 'active'
    return listings

  transactionsData: ->
    transactions =_.clone(Items.transactions)
    _.extend transactions.inventorying,
      label: 'just_inventorize_it'
      classes: 'active'
    return transactions

  setAddModeSpecificAttr: (attrs)->
    # if mobile and last add mode is scan
    # set #validateAndAddNext href to the scanner.url
    if _.isMobile
      @_addMode = app.request 'last:add:mode:get'
      if @_addMode is 'scan' then attrs.scanner = scanner
    return attrs

  events:
    'click .select-button-group > .button': 'updateSelector'
    'click #transaction': 'updateTransaction'
    'click #listing': 'updateListing'
    'click #cancel': 'destroyItem'
    'click #validate': 'validateSimple'
    'click #validateAndAddNext': 'validateAndAddNext'

  showEntityData: ->
    @entityRegion.show new EntityData { model: @entity }

  updateSelector: (e)->
    $el = $(e.currentTarget)
    $el.siblings().removeClass 'active'
    $el.addClass 'active'

  # TODO: update the UI for update errors
  updateTransaction: ->
    transaction = @ui.transaction.find('.active').attr 'id'
    app.execute 'last:transaction:set', transaction
    @updateItem { transaction: transaction }
    .catch _.Error('updateTransaction err')

  updateListing: ->
    listing = @ui.listing.find('.active').attr 'id'
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
