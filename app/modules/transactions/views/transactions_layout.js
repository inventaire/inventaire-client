import Transaction from '#app/modules/transactions/views/focused_transaction_layout'
import TransactionsList from '#modules/transactions/views/transactions_list'
import folders from '../lib/folders'
import transactionsLayoutTemplate from './templates/transactions_layout.hbs'
import '../scss/transactions_layout.scss'

const foldersNames = Object.keys(folders)

export default Marionette.View.extend({
  className: 'transactionsLayout',
  template: transactionsLayoutTemplate,
  regions: {
    ongoingRegion: '#ongoing',
    archivedRegion: '#archived',
    fullviewRegion: '#fullview'
  },

  initialize () {
    this.listenTo(app.vent, {
      'transaction:select': this.showTransactionFull.bind(this),
      'transactions:welcome': this.showTransactionWelcome.bind(this)
    })
  },

  serializeData () { return { folders } },

  onRender () { this.showTransactionsFolders() },

  showTransactionsFolders () {
    // every folder share the app.transactions collection
    // but with the filter applied by TransactionsList
    // => there should be a region matching every filter's name
    foldersNames.map(folder => this.showTransactionList(folder))
  },

  showTransactionList (folder) {
    this.showChildView(`${folder}Region`, new TransactionsList({
      folder,
      collection: app.transactions
    }))
  },

  showTransactionFull (transaction, nonExplicitSelection) {
    this.showChildView('fullviewRegion', new Transaction({ model: transaction, nonExplicitSelection }))
  },

  events: {
    'click label': 'toggleSection'
  },

  toggleSection (e) {
    const region = e.currentTarget.htmlFor
    $(e.currentTarget).toggleClass('toggled')
    return $(`#${region}`).slideToggle(200)
  },

  async showTransactionWelcome () {
    const { default: TransactionsWelcome } = await import('./transactions_welcome')
    this.showChildView('fullviewRegion', new TransactionsWelcome())
    app.navigate('transactions')
  }
})
