Item = require 'modules/inventory/models/item'

module.exports = ItemCreation = Backbone.Marionette.ItemView.extend
  template: require './templates/item_creation'
  className: "addEntity"
  initialize: ->
    console.log('item creation arguments', arguments)
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

  ui:
    'transaction': '#transaction'
    'listing': '#listing'
    'comment': '#comment'
    'notes': '#notes'

  onShow: ->
    app.execute 'foundation:reload'
    @updateTransaction()

  updateTransaction: ->
    transaction = @model.get 'transaction'
    if transaction?
      _.log transaction, 'transaction'
      $transaction = @ui.transaction.find "a[id=#{transaction}]"
      _.log $transaction, '$transaction'
      if $transaction.length is 1
        @ui.transaction.find('a').removeClass 'active'
        $transaction.addClass 'active'


  serializeData: ->
    attrs =
      entity: @entity.toJSON()
      title: @entity.get 'title'
      listings: app.user.listings
    attrs.header = _.i18n 'add_item_text', {title: attrs.title}
    return attrs

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
    comment = @ui.comment.val()
    notes = @ui.notes.val()

    unless listing? then throw new Error 'listing value missing'
    unless transaction? then throw new Error 'transaction value missing'
    @model.set 'transaction', transaction
    @model.set 'listing', listing
    @model.set 'comment', comment  if comment?
    @model.set 'notes', notes  if notes?
