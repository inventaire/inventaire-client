Item = require 'modules/inventory/models/item'
EntityData = require 'modules/entities/views/entity_data'

module.exports = Marionette.LayoutView.extend
  template: require './templates/item_creation'
  className: "addEntity"
  regions:
    entityRegion: '#entity'

  initialize: ->
    @entity = @options.entity
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

    if attrs.entity? and attrs.title?
      @model = new Item attrs
    else throw new Error 'missing uri or title at item creation from entity'

  behaviors:
    ElasticTextarea: {}

  ui:
    'transaction': '#transaction'
    'listing': '#listing'
    'details': '#details'
    'notes': '#notes'

  onShow: ->
    app.execute 'foundation:reload'
    @updateTransaction()
    @showEntityData()

  updateTransaction: ->
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
    listings.friends.classes = 'active'
    return listings

  transactionsData: ->
    transactions =_.clone(Items.transactions)
    _.extend transactions.inventorying,
      label: 'just_inventorize_it'
      classes: 'active'
    return transactions

  events:
    'click .select-button-group > .button': 'updateSelector'
    'click #validate': 'validateItem'
    'click #cancel': -> app.execute 'show:home'

  updateSelector: (e)->
    $el = $(e.currentTarget)
    $el.siblings().removeClass('active')
    $el.addClass('active')

  validateItem: ->
    @setFormData()
    itemData = @model.toJSON()
    if app.request 'item:validate:creation', itemData
      app.execute 'show:home'
    else throw new Error "couldn't validateItem"

  setFormData: ->
    transaction = @ui.transaction.find('.active').attr('id')
    listing = @ui.listing.find('.active').attr('id')
    details = @ui.details.val()
    notes = @ui.notes.val()

    unless listing? then throw new Error 'listing value missing'
    unless transaction? then throw new Error 'transaction value missing'
    @model.set 'transaction', transaction
    @model.set 'listing', listing
    @model.set 'details', details  if details?
    @model.set 'notes', notes  if notes?

  showEntityData: ->
    @entityRegion.show new EntityData { model: @entity }
