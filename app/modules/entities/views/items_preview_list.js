import { data as transactionsData } from 'modules/inventory/lib/transactions_data'

export default Marionette.CompositeView.extend({
  template: require('./templates/items_preview_list.hbs'),
  className () {
    let className = 'itemsPreviewList'
    if (this.options.compact) { className += ' compact' }
    return className
  },

  childViewContainer: '.items-preview',
  childView: require('./item_preview'),
  childViewOptions () {
    return {
      displayItemsCovers: this.options.displayItemsCovers,
      compact: this.options.compact
    }
  },

  initialize () {
    return ({ transaction: this.transaction } = this.options)
  },

  serializeData () {
    return {
      transaction: this.transaction,
      icon: transactionsData[this.transaction].icon
    }
  }
})
