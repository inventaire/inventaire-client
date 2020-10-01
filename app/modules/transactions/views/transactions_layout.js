import Transaction from 'modules/transactions/views/transaction'
import TransactionsList from 'modules/transactions/views/transactions_list'
import TransactionsWelcome from './transactions_welcome'
import * as folders from '../lib/folders'
const foldersNames = Object.keys(folders)

export default Marionette.LayoutView.extend({
  className: 'transactionsLayout',
  template: require('./templates/transactions_layout'),
  regions: {
    ongoingRegion: '#ongoing',
    archivedRegion: '#archived',
    fullviewRegion: '#fullview'
  },

  initialize () {
    return this.listenTo(app.vent, {
      'transaction:select': this.showTransactionFull.bind(this),
      'transactions:welcome': this.showTransactionWelcome.bind(this)
    })
  },

  serializeData () { return { folders } },

  onShow () { return this.showTransactionsFolders() },

  showTransactionsFolders () {
    // every folder share the app.transactions collection
    // but with the filter applied by TransactionsList
    // => there should be a region matching every filter's name
    return foldersNames.map(folder => this.showTransactionList(folder))
  },

  showTransactionList (folder) {
    return this[`${folder}Region`].show(new TransactionsList({
      folder,
      collection: app.transactions
    })
    )
  },

  showTransactionFull (transaction, nonExplicitSelection) {
    return this.fullviewRegion.show(new Transaction({ model: transaction, nonExplicitSelection }))
  },

  events: {
    'click label': 'toggleSection'
  },

  toggleSection (e) {
    const region = e.currentTarget.htmlFor
    $(e.currentTarget).toggleClass('toggled')
    return $(`#${region}`).slideToggle(200)
  },

  showTransactionWelcome () {
    this.fullviewRegion.show(new TransactionsWelcome())
    return app.navigate('transactions')
  }
})
