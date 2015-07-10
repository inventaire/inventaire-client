itemActions = require '../plugins/item_actions'
itemUpdaters = require '../plugins/item_updaters'
detailsLimit = 150

module.exports = Marionette.ItemView.extend
  tagName: 'figure'
  className: ->
    @uniqueSelector = ".#{@cid}"
    "itemContainer #{@cid}"
  template: require './templates/item_figure'
  behaviors:
    PreventDefault: {}
    ConfirmationModal: {}

  initialize: ->
    @initPlugins()
    @lazyRender = _.debounce @render.bind(@), 400
    @listenTo @model, 'change', @lazyRender
    @listenTo @model, 'grab:entity', @lazyRender

  initPlugins: ->
    itemActions.call @
    itemUpdaters.call @

  onRender: ->
    app.execute 'foundation:reload'
    app.request 'qLabel:update'

  events:
    'click .edit': 'itemEdit'
    'click a.requestItem': -> app.execute 'show:item:request', @model

  serializeData: ->
    attrs = @model.serializeData()
    # attrs.wrap = @wrapData(attrs)
    attrs.date = {date: attrs.created}
    attrs.details = @detailsData attrs.details
    return attrs

  itemEdit: -> app.execute 'show:item:form:edition', @model

  detailsData: (details)->
    if details?.length > detailsLimit
      more = _.i18n 'see more'
      return details[0..detailsLimit] + "...  <a class='itemShow more'>#{more}</a>"
    else details
