module.exports = Marionette.ItemView.extend
  template: require './templates/transaction_preview'
  className: 'transactionPreview'
  behaviors:
    PreventDefault: {}

  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo app.vent, 'transaction:select', @autoSelect.bind(@)
    # Required by @requestContext
    @model.buildTimeline()

  serializeData: ->
    _.extend @model.serializeData(),
      onItem: @options.onItem
      requestContext: @requestContext()

  modelEvents:
    'grab': 'lazyRender'
    'change:read': 'lazyRender'

  events:
    'click .showTransaction': 'showTransaction'

  ui:
    showTransaction: 'a.showTransaction'

  onRender: ->
    if app.request('last:transaction:id') is @model.id
      @$el.addClass 'selected'

  showTransaction: (e)->
    unless _.isOpenedOutside(e)
      if @options.onItem
        app.execute 'show:transaction', @model.id
        # Required to close the ItemShow modal if one was open
        app.execute 'modal:close'
      else
        app.vent.trigger 'transaction:select', @model

  autoSelect: (transac)->
    if transac is @model then @$el.addClass 'selected'
    else @$el.removeClass 'selected'

  requestContext: ->
    # first action context
    @model.timeline.models[0].context()
