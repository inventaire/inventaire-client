module.exports = Marionette.CompositeView.extend
  className: 'itemsPreviewList flex-row-center-start'
  template: require './templates/items_preview_list'
  childViewContainer: '.items-preview'
  childView: require './item_preview'
  initialize: ->
    { @transaction } = @options

  serializeData: ->
    transaction: @transaction
    icon: app.items.transactions.data[@transaction].icon
