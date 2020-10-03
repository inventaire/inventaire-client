import InfiniteScrollItemsList from './infinite_scroll_items_list'
import masonryPlugin from 'modules/general/plugins/masonry'

export default InfiniteScrollItemsList.extend({
  className: 'items-cascade-wrapper',
  template: require('./templates/items_cascade.hbs'),
  childViewContainer: '.itemsCascade',
  childView: require('./item_card'),
  emptyView: require('./no_item'),

  ui: {
    itemsCascade: '.itemsCascade'
  },

  childViewOptions () {
    return { showDistance: this.options.showDistance }
  },

  initialize () {
    this.initInfiniteScroll()

    return masonryPlugin.call(this, '.itemsCascade', '.itemCard')
  },

  serializeData () {
    return { header: this.options.header }
  },

  collectionEvents: {
    'filtered:add': 'lazyMasonryRefresh'
  },

  childEvents: {
    render: 'lazyMasonryRefresh',
    resize: 'lazyMasonryRefresh'
  }
})
