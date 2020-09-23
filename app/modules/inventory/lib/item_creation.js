/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { factory as transactionsDataFactory } from './transactions_data'

export default {
  listingsData (selectedListing) {
    if (selectedListing == null) { selectedListing = app.request('last:listing:get') || 'private' }
    const listings = app.user.listings()
    const selectedListingData = listings[selectedListing]
    selectedListingData.classes = 'selected'
    return listings
  },

  transactionsData (selectedTransaction) {
    if (selectedTransaction == null) { selectedTransaction = app.request('last:transaction:get') || 'inventorying' }
    const transactions = transactionsDataFactory()
    transactions.inventorying.label = 'just_inventorize_it'
    const selectedTransactionData = transactions[selectedTransaction]
    selectedTransactionData.classes = 'selected'
    return transactions
  },

  // assume that the view has a ui like so
  // ui:
  //   transaction: '#transaction'
  //   listing: '#listing'
  getSelectorData (view, attr) {
    return view.ui[attr].find('.selected').attr('id')
  }
}
