import folders from '../lib/folders'
import TransactionPreview from './transaction_preview'
import NoTransaction from './no_transaction'
import transactionsListTemplate from './templates/transactions_list.hbs'
import '../scss/transactions_list.scss'

export default Marionette.CompositeView.extend({
  template: transactionsListTemplate,
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
