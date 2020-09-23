detailsLimit = 150
itemViewsCommons = require '../lib/items_views_commons'
ItemItemView = Marionette.ItemView.extend itemViewsCommons

module.exports = ItemItemView.extend
  tagName: 'figure'
  className: ->
    busy = if @model.get('busy') then 'busy' else ''
    return "itemCard #{busy}"
  template: require './templates/item_card'
  behaviors:
    PreventDefault: {}
    AlertBox: {}

  initialize: ->
    @alertBoxTarget = '.details'

  modelEvents:
    'change': 'lazyRender'
    'user:ready': 'lazyRender'

  onRender: ->
    app.execute 'uriLabel:update'

  events:
    'click a.transaction': 'updateTransaction'
    'click a.listing': 'updateListing'
    'click a.remove': 'itemDestroy'
    'click a.itemShow': 'itemShow'
    'click a.user': 'showUser'
    'click a.showUser': 'showUser'
    'click a.requestItem': -> app.execute 'show:item:request', @model

  serializeData: ->
    attrs = @model.serializeData()
    attrs.date = { date: attrs.created }
    attrs.detailsMore = @detailsMoreData attrs.details
    attrs.details = @detailsData attrs.details
    attrs.showDistance = @options.showDistance and attrs.user?.distance?
    return attrs

  itemEdit: -> app.execute 'show:item:form:edition', @model

  detailsMoreData: (details)->
    if details?.length > detailsLimit then true
    else false

  detailsData: (details)->
    if details?.length > detailsLimit
      # Avoid to cut at the middle of a word as it might be a link
      # and thus the rendered link would be clickable but incomplete
      # Let a space before the ... so that it wont be taken as the end
      # of a link
      return _.cutBeforeWord(details, detailsLimit) + ' ...'
    else
      return details

  afterDestroy: -> @model.collection.remove @model
