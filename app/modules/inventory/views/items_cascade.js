import InfiniteScrollItemsList from './infinite_scroll_items_list'
import masonryPlugin from 'modules/general/plugins/masonry'
import NoItem from 'modules/inventory/views/no_item'
import ItemCard from './item_card'
import itemsCascadeTemplate from './templates/items_cascade.hbs'

export default InfiniteScrollItemsList.extend({
  className: 'items-cascade-wrapper',
  template: itemsCascadeTemplate,
  childViewContainer: '.itemsCascade',
  childView: ItemCard,
  emptyView: NoItem,

  ui: {
    itemsCascade: '.itemsCascade'
  },

  childViewOptions () {
    return { showDistance: this.options.showDistance }
  },

  initialize () {
    this.initInfiniteScroll()
    masonryPlugin.call(this, '.itemsCascade', '.itemCard')
  },

  serializeData () {
    return { header: this.options.header }
  },

  lazyMasonryRefresh () {
    if (this._lazyMasonryRefresh != null) this._lazyMasonryRefresh()
  },

  collectionEvents: {
    'filtered:add': 'lazyMasonryRefresh'
  },

  childEvents: {
    render: 'lazyMasonryRefresh',
    resize: 'lazyMasonryRefresh'
  }
})
