import TransactionPreview from '#transactions/views/transaction_preview'
import itemTransactionsTemplate from './templates/item_transactions.hbs'

export default Marionette.CollectionView.extend({
  className: 'itemTransactions',
  template: itemTransactionsTemplate,
  childViewContainer: '.transactions',
  childView: TransactionPreview,
  childViewOptions: {
    onItem: true
  }
})
