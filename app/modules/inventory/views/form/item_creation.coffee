EntityData = require 'modules/entities/views/entity_data'

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
      transaction: @options.transaction

    if pictures = @entity.get 'pictures'
      attrs.pictures = pictures

    # will be confirmed by the server
    attrs.owner = app.user.id
    unless attrs.entity? and attrs.title?
      throw new Error 'missing uri or title at item creation from entity'

    @model = app.request 'item:create', attrs

  onShow: ->
    app.execute 'foundation:reload'
    @selectTransaction()
    @showEntityData()

  selectTransaction: ->
    transaction = @model.get 'transaction'
    if transaction?
      $transaction = @ui.transaction.find "a[id=#{transaction}]"
      if $transaction.length is 1
        @ui.transaction.find('a').removeClass 'active'
        $transaction.addClass 'active'

  serializeData: ->
    title = @entity.get('title')
    return attrs =
      title: title
      listings: @listingsData()
      transactions: @transactionsData()
      header: _.i18n 'add_item_text', {title: title}

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

  events:
    'click .select-button-group > .button': 'updateSelector'
    'click #cancel': -> app.execute 'show:home'
    'click #transaction': 'updateTransaction'
    'click #listing': 'updateListing'
    'click #validate': 'validateItem'

  showEntityData: ->
    _.log 'showEntityData?'
    @entityRegion.show new EntityData { model: @entity }

  updateSelector: (e)->
    $el = $(e.currentTarget)
    $el.siblings().removeClass 'active'
    $el.addClass 'active'

  # TODO: update the UI for update errors
  updateTransaction: ->
    transaction = @ui.transaction.find('.active').attr 'id'
    @updateItem { transaction: transaction }
    .catch _.Error('updateTransaction err')

  updateListing: ->
    listing = @ui.listing.find('.active').attr 'id'
    @updateItem { listing: listing }
    .catch _.Error('updateListing err')

  validateItem: ->
    @updateItem
      details: @ui.details.val()
      notes: @ui.notes.val()
    .then -> app.execute 'show:home'
    .catch _.Error('validateItem err')

  updateItem: (data)->
    app.request 'item:update',
      item: @model
      data: data
