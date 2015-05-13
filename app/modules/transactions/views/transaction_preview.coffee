module.exports = Marionette.ItemView.extend
  template: require './templates/transaction_preview'
  className: 'transactionPreview'
  initialize: ->
    @lazyRender = _.debounce @render.bind(@), 200

  serializeData: -> @model.serializeData()

  modelEvents:
    'grab': 'lazyRender'

  events:
    'click': 'select'

  select: ->
    app.vent.trigger 'transaction:select', @model
