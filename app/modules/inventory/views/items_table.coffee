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
    updators: '.selector, .delete'

  initialize: ->
    @initInfiniteScroll()
    { @allItemsIds, @isMainUser } = @options
    @selectedIds = []
    @getSelectedIds = => @selectedIds

  childViewOptions: -> { @getSelectedIds, @isMainUser }

  serializeData: ->
    itemsCount: @allItemsIds.length
    transactions: transactionsData
    listings: app.user.listings()
    isMainUser: @isMainUser

  events:
    'inview .fetchMore': 'infiniteScroll'
    'click #selectAll': 'selectAll'
    'click #unselectAll': 'unselectAll'
    'click .transaction-option': 'setTransaction'
    'click .listing-option': 'setListing'
    'change input[name="select"]': 'selectOne'
    'click .delete': 'deleteItems'

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
      else @addSelectedIds id
    else
      if id not in @selectedIds then return
      else @removeSelectedIds id

  updateSelectedIds: (list)->
    @selectedIds = list
    if list.length is 0
      @ui.unselectAll.addClass 'disabled'
      @ui.updators.addClass 'disabled'
    else
      @ui.unselectAll.removeClass 'disabled'
      @ui.updators.removeClass 'disabled'

  addSelectedIds: (ids...)->
    @selectedIds.push ids...
    @updateSelectedIds @selectedIds

  removeSelectedIds: (ids...)->
    @selectedIds = _.without @selectedIds, ids...
    @updateSelectedIds @selectedIds

  setTransaction: (e)-> @updateItems e, 'transaction'

  setListing: (e)-> @updateItems e, 'listing'

  updateItems: (e, attribute)->
    value = e.currentTarget.id
    { selectedModelsAndIds } = @getSelectedModelsAndIds()
    app.request 'items:update', { items: selectedModelsAndIds, attribute, value }

  deleteItems: ->
    { selectedModelsAndIds, selectedModels, selectedIds } = @getSelectedModelsAndIds()

    app.request 'items:delete',
      items: selectedModelsAndIds
      next: @options.afterItemsDelete

  # Get a mix of the selected views' models and the remaining ids from non-displayed
  # items so that items:update or items:delete can set values on models
  # trigger item rows updates
  getSelectedModelsAndIds: ->
    { selectedIds } = @

    selectedModels = @children
      .filter (view)-> view.model.id in selectedIds
      .map _.property('model')

    modelsIds = _.pluck selectedModels, 'id'
    otherIds = _.difference selectedIds, modelsIds
    selectedModelsAndIds = selectedModels.concat otherIds
    return { selectedModelsAndIds, selectedModels, selectedIds }
