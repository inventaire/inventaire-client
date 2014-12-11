Item = require 'modules/inventory/models/item'

module.exports = class ItemCreation extends Backbone.Marionette.ItemView
  template: require './templates/item_creation'
  className: "addEntity"
  initialize: ->
    @entity = @options.entity
    attrs =
      title: @entity.get 'title'
      entity: @entity.get 'uri'
      claims:
        P31: @entity.get 'uri'
      transaction: @options.transaction

    if pictures = @entity.get 'pictures'
      attrs.pictures = pictures

    attrs.owner = app.user.id

    if attrs.entity? and attrs.title?
      @model = new Item attrs
    else throw new Error 'missing uri or title at item creation from entity'

  ui:
    'transaction': '#transaction'

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
    # 'selected:selling': -

  updateSelector: (e)->
    $el = $(e.currentTarget)
    value = $el.attr('id')
    category = $el.parent().attr('id')
    console.log value, category
    @$el.trigger "change:#{value}"
    @$el.trigger "selected:#{value}"
    $el.siblings().removeClass('active')
    $el.addClass('active')

  validateItem: ->
    transaction = $('#transaction').find('.active').first().attr('id')
    comment = $('#comment').val()
    notes = $('#notes').val()
    listing = $('#listing').find('.active').first().attr('id')
    if listing?
      @model.set 'listing', listing
      @model.set 'comment', comment  if comment?
      @model.set 'notes', notes  if notes?
      @model.set 'transaction', transaction  if transaction?
      itemData = @model.toJSON()
      if app.request 'item:validate:creation', itemData
        app.execute 'show:home'
      else throw new Error "couldn't validateItem"
    else throw new Error 'no value found for the listing'

