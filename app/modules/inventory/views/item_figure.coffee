itemActions = require '../plugins/item_actions'
itemUpdaters = require '../plugins/item_updaters'
detailsLimit = 150

module.exports = Marionette.ItemView.extend
  tagName: 'figure'
  className: ->
    busy = if @model.get('busy') then 'busy' else ''
    return "itemContainer #{busy}"
  template: require './templates/item_figure'
  behaviors:
    PreventDefault: {}
    AlertBox: {}

  initialize: ->
    @initPlugins()
    @lazyRender = _.LazyRender @, 400
    @listenTo @model, 'change', @lazyRender
    @listenTo @model, 'user:ready', @lazyRender
    @alertBoxTarget = '.details'
    # Should not be required
    # @listenTo @model, 'grab:entity', @lazyRender

  initPlugins: ->
    itemActions.call @
    itemUpdaters.call @

  onRender: ->
    app.execute 'uriLabel:update'

  events:
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
