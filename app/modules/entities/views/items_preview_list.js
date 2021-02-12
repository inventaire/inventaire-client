import { transactionsData } from 'modules/inventory/lib/transactions_data'
import ItemPreview from './item_preview'
import itemsPreviewListTemplate from './templates/items_preview_list.hbs'

export default Marionette.CompositeView.extend({
  template: itemsPreviewListTemplate,
  className () {
    let className = 'itemsPreviewList'
    if (this.options.compact) className += ' compact'
    return className
  },

  childViewContainer: '.items-preview',
  childView: ItemPreview,
  childViewOptions () {
    return {
      displayItemsCovers: this.options.displayItemsCovers,
      compact: this.options.compact
    }
  },

  initialize () {
    this.transaction = this.options.transaction
  },

  serializeData () {
    return {
      transaction: this.transaction,
      icon: transactionsData[this.transaction].icon
    }
  }
})
