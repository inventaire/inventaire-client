import InfiniteScrollItemsList from './infinite_scroll_items_list'
import ItemsTableSelectionEditor from './items_table_selection_editor'

export default InfiniteScrollItemsList.extend({
  className: 'items-table',
  template: require('./templates/items_table'),
  childView: require('./item_row'),
  emptyView: require('./no_item'),
  childViewContainer: '#itemsRows',

  ui: {
    selectAll: '#selectAll',
    unselectAll: '#unselectAll',
    editSelection: '#editSelection',
    selectionCounter: '.selectionCounter'
  },

  initialize () {
    this.initInfiniteScroll();
    ({ itemsIds: this.itemsIds, isMainUser: this.isMainUser, groupContext: this.groupContext } = this.options)
    this.selectedIds = []
    this.getSelectedIds = () => this.selectedIds
  },

  childViewOptions () { return { getSelectedIds: this.getSelectedIds, isMainUser: this.isMainUser, groupContext: this.groupContext } },

  serializeData () {
    return {
      itemsCount: this.itemsIds.length,
      isMainUser: this.isMainUser
    }
  },

  events: {
    'inview .fetchMore': 'infiniteScroll',
    'click #selectAll': 'selectAll',
    'click #unselectAll': 'unselectAll',
    'click #editSelection': 'showSelectionEditor',
    'change input[name="select"]': 'selectOne'
  },

  selectAll () {
    this.$el.find('input:checkbox').prop('checked', true)
    return this.updateSelectedIds(_.clone(this.itemsIds))
  },

  unselectAll () {
    this.$el.find('input:checkbox').prop('checked', false)
    return this.updateSelectedIds([])
  },

  selectOne (e) {
    const { checked } = e.currentTarget
    const id = e.currentTarget.attributes['data-id'].value
    if (checked) {
      if (this.selectedIds.includes(id)) {

      } else { return this.addSelectedIds(id) }
    } else {
      if (!this.selectedIds.includes(id)) {

      } else { return this.removeSelectedIds(id) }
    }
  },

  updateSelectedIds (list) {
    this.selectedIds = list

    if (list.length === 0) {
      this.ui.unselectAll.addClass('hidden')
      this.ui.editSelection.addClass('hidden')
    } else {
      this.ui.unselectAll.removeClass('hidden')
      this.ui.editSelection.removeClass('hidden')
      this.ui.selectionCounter.text(`(${list.length})`)
    }

    if (list.length === this.itemsIds.length) {
      this.ui.selectAll.addClass('hidden')
    } else {
      this.ui.selectAll.removeClass('hidden')
    }
  },

  addSelectedIds (...ids) {
    this.selectedIds.push(...Array.from(ids || []))
    return this.updateSelectedIds(this.selectedIds)
  },

  removeSelectedIds (...ids) {
    this.selectedIds = _.without(this.selectedIds, ...Array.from(ids))
    return this.updateSelectedIds(this.selectedIds)
  },

  // Get a mix of the selected views' models and the remaining ids from non-displayed
  // items so that items:update or items:delete can set values on models
  // trigger item rows updates
  getSelectedModelsAndIds () {
    const { selectedIds } = this

    const selectedModels = this.children
      .filter(view => selectedIds.includes(view.model.id))
      .map(_.property('model'))

    const modelsIds = _.pluck(selectedModels, 'id')
    const otherIds = _.difference(selectedIds, modelsIds)
    const selectedModelsAndIds = selectedModels.concat(otherIds)
    return { selectedModelsAndIds, selectedModels, selectedIds }
  },

  showSelectionEditor () {
    return app.layout.modal.show(new ItemsTableSelectionEditor({
      selectedIds: this.selectedIds,
      getSelectedModelsAndIds: this.getSelectedModelsAndIds.bind(this),
      afterItemsDelete: this.options.afterItemsDelete
    })
    )
  }
})
