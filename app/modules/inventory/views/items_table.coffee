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
    updators: '.selector'
    deleteUpdators: '.delete'

  initialize: ->
    @initInfiniteScroll()
    { @itemsIds, @isMainUser } = @options
    @selectedIds = []
    @getSelectedIds = => @selectedIds

  childViewOptions: -> { @getSelectedIds, @isMainUser }

  serializeData: ->
    itemsCount: @itemsIds.length
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
    @updateSelectedIds _.clone(@itemsIds)

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
      @ui.unselectAll.addClass 'hidden'
      @ui.updators.addClass 'hidden'
      @ui.deleteUpdators.addClass 'hidden'
    else
      @ui.unselectAll.removeClass 'hidden'
      @ui.updators.removeClass 'hidden'
      @ui.deleteUpdators.removeClass 'hidden'

    if list.length is @itemsIds.length
      @ui.selectAll.addClass 'hidden'
    else
      @ui.selectAll.removeClass 'hidden'

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
    action = -> app.request 'items:update', { items: selectedModelsAndIds, attribute, value }
    editedItemsCount = selectedModelsAndIds.length

    if selectedModelsAndIds.length is 1
      action()
    else
      app.execute 'ask:confirmation',
        confirmationText: _.I18n 'confirmation_items_edit', { count: editedItemsCount }
        yesButtonClass: 'success'
        action: action

  deleteItems: ->
    if @selectedIds.length is 0 then return

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
