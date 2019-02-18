InfiniteScrollItemsList = require './infinite_scroll_items_list'
{ data: transactionsData } = require '../lib/transactions_data'

module.exports = InfiniteScrollItemsList.extend
  className: 'items-table'
  template: require './templates/items_table'
  childView: require './item_row'
  emptyView: require './no_item'
  childViewContainer: '#itemsRows'

  ui:
    selectTransaction: '#selectTransaction'

  initialize: ->
    @initInfiniteScroll()
    { @allItemsIds } = @options
    @selectedIds = []

  serializeData: ->
    itemsCount: @allItemsIds.length
    transactions: transactionsData
    listings: app.user.listings()

  events:
    'inview .fetchMore': 'infiniteScroll'
    'click #selectAll': 'selectAll'
    'click #unselectAll': 'unselectAll'
    'click .transaction-option': 'setTransaction'
    'click .listing-option': 'setListing'
    'change input[name="select"]': 'selectOne'

  selectAll: ->
    @$el.find('input:checkbox').prop 'checked', true
    @selectedIds = _.clone @allItemsIds

  unselectAll: ->
    @$el.find('input:checkbox').prop 'checked', false
    @selectedIds = []

  selectOne: (e)->
    { checked } = e.currentTarget
    id = e.currentTarget.attributes['data-id'].value
    if checked
      if id in @selectedIds then return
      else @selectedIds.push id
    else
      if id not in @selectedIds then return
      else @selectedIds = _.without @selectedIds, id

  setTransaction: (e)-> @updateItems e, 'transaction'

  setListing: (e)-> @updateItems e, 'listing'

  updateItems: (e, attribute)->
    value = e.currentTarget.id
    # Pass a mix of the selected views' models and the remaining ids from non-displayed
    # items so that items:update can set values on models and trigger item rows re-render
    items = @getSelectedModelsAndIds()
    app.request 'items:update', { items, attribute, value }

  getSelectedModelsAndIds: ->
    { selectedIds } = @

    selectedModels = @children
      .filter (view)-> view.model.id in selectedIds
      .map _.property('model')

    modelsIds = _.pluck selectedModels, 'id'
    otherIds = _.difference selectedIds, modelsIds
    return selectedModels.concat otherIds
