import * as folders from '../lib/folders'
import TransactionPreview from './transaction_preview'
import NoTransaction from './no_transaction'

export default Marionette.CompositeView.extend({
  template: require('./templates/transactions_list.hbs'),
  className: 'transactionList',
  childViewContainer: '.transactions',
  childView: TransactionPreview,
  emptyView: NoTransaction,
  initialize () {
    this.folder = this.options.folder
    this.filter = folders[this.folder].filter
    this.listenTo(app.vent, 'transactions:folder:change', this.render.bind(this))
  },

  serializeData () {
    const attrs = {}
    attrs[this.folder] = true
    return attrs
  }
})
