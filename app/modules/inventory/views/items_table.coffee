InfiniteScrollItemsList = require './infinite_scroll_items_list'
{ data: transactionsData } = require '../lib/transactions_data'

module.exports = InfiniteScrollItemsList.extend
  className: 'items-table'
  template: require './templates/items_table'
  childView: require './item_row'
  emptyView: require './no_item'
  childViewContainer: '#itemsRows'

  ui:
    selectAll: '#selectAll'
    unselectAll: '#unselectAll'
    selectors: '.selector'

  initialize: ->
    @initInfiniteScroll()
    { @allItemsIds } = @options
    @selectedIds = []
    @getSelectedIds = => @selectedIds

  childViewOptions: -> { @getSelectedIds }

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
    @updateSelectedIds _.clone(@allItemsIds)

  unselectAll: ->
    @$el.find('input:checkbox').prop 'checked', false
    @updateSelectedIds []

  selectOne: (e)->
    { checked } = e.currentTarget
    id = e.currentTarget.attributes['data-id'].value
    if checked
      if id in @selectedIds then return
      else @addSelectedId id
    else
      if id not in @selectedIds then return
      else @removeSelectedId id

  updateSelectedIds: (list)->
    @selectedIds = list
    if list.length is 0
      @ui.unselectAll.addClass 'disabled'
      @ui.selectors.addClass 'disabled'
    else
      @ui.unselectAll.removeClass 'disabled'
      @ui.selectors.removeClass 'disabled'

  addSelectedId: (id)->
    @selectedIds.push id
    @updateSelectedIds @selectedIds

  removeSelectedId: (id)->
    @selectedIds = _.without @selectedIds, id
    @updateSelectedIds @selectedIds

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
