module.exports = Marionette.ItemView.extend
  template: require './templates/transaction_preview'
  className: 'transactionPreview'
  initialize: ->
    @lazyRender = _.debounce @render.bind(@), 200
    @listenTo app.vent, 'transaction:select', @autoSelect.bind(@)

  serializeData: -> @model.serializeData()

  modelEvents:
    'grab': 'lazyRender'

  events:
    'click': 'select'

  onRender: ->
    if app.request('last:transaction:id') is @model.id
      @$el.addClass 'selected'

  select: ->
    app.vent.trigger 'transaction:select', @model

  autoSelect: (transac)->
    if transac is @model then @$el.addClass 'selected'
    else @$el.removeClass 'selected'
