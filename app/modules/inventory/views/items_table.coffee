InfiniteScrollItemsList = require './infinite_scroll_items_list'
ItemsTableSelectionEditor = require './items_table_selection_editor'

module.exports = InfiniteScrollItemsList.extend
  className: 'items-table'
  template: require './templates/items_table'
  childView: require './item_row'
  emptyView: require './no_item'
  childViewContainer: '#itemsRows'

  ui:
    selectAll: '#selectAll'
    unselectAll: '#unselectAll'
    editSelection: '#editSelection'
    selectionCounter: '.selectionCounter'

  initialize: ->
    @initInfiniteScroll()
    { @itemsIds, @isMainUser } = @options
    @selectedIds = []
    @getSelectedIds = => @selectedIds

  childViewOptions: -> { @getSelectedIds, @isMainUser }

  serializeData: ->
    itemsCount: @itemsIds.length
    isMainUser: @isMainUser

  events:
    'inview .fetchMore': 'infiniteScroll'
    'click #selectAll': 'selectAll'
    'click #unselectAll': 'unselectAll'
    'click #editSelection': 'showSelectionEditor'
    'change input[name="select"]': 'selectOne'

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
      @ui.editSelection.addClass 'hidden'
    else
      @ui.unselectAll.removeClass 'hidden'
      @ui.editSelection.removeClass 'hidden'
      @ui.selectionCounter.text "(#{list.length})"

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

  showSelectionEditor: ->
    app.layout.modal.show new ItemsTableSelectionEditor
      selectedIds: @selectedIds
      getSelectedModelsAndIds: @getSelectedModelsAndIds.bind(@)
      afterItemsDelete: @options.afterItemsDelete
