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

  events:
    'inview .fetchMore': 'infiniteScroll'
    'click #selectAll': 'selectAll'
    'click #unselectAll': 'unselectAll'
    'click .transaction-option': 'setTransaction'
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

  setTransaction: (e)->
    { id: transaction } = e.currentTarget
    alert { transaction, @selectedIds }
